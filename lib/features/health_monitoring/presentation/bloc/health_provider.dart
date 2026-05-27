import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_anomaly.dart';
import '../../domain/entities/health_reading.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/usecases/detect_anomalies_usecase.dart';
import '../../domain/usecases/fetch_health_data_usecase.dart';
import '../../domain/usecases/save_health_event_usecase.dart';
import '../../services/health_monitoring_service.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class HealthState {
  const HealthState();
}

final class HealthInitial extends HealthState {
  const HealthInitial();
}

final class HealthLoading extends HealthState {
  const HealthLoading();
}

final class HealthPermissionRequired extends HealthState {
  const HealthPermissionRequired();
}

final class HealthData extends HealthState {
  const HealthData({required this.latestReadings, this.activeAnomaly});

  final Map<HealthReadingType, HealthReading?> latestReadings;
  final HealthAnomaly? activeAnomaly;

  HealthData copyWith({
    Map<HealthReadingType, HealthReading?>? latestReadings,
    HealthAnomaly? activeAnomaly,
  }) =>
      HealthData(
        latestReadings: latestReadings ?? this.latestReadings,
        activeAnomaly: activeAnomaly ?? this.activeAnomaly,
      );
}

final class HealthError extends HealthState {
  const HealthError(this.message);
  final String message;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class HealthNotifier extends AsyncNotifier<HealthState> {
  final Map<HealthReadingType, HealthReading?> _latestReadings = {};
  Timer? _pollingTimer;

  static const _monitoredTypes = [
    HealthReadingType.heartRate,
    HealthReadingType.steps,
  ];

  @override
  Future<HealthState> build() async {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    final user = ref.watch(currentUserProvider);
    if (user == null) return const HealthInitial();

    final repo = ref.read(healthRepositoryProvider);
    final hasPerms = await repo.hasHealthPermissions(_monitoredTypes);
    if (!hasPerms) return const HealthPermissionRequired();

    await HealthMonitoringService.startService(
      userId: user.uid,
      householdId: user.householdId,
    );

    // Poll immediately then every 5 minutes
    await _poll(user.uid, user.householdId);

    _pollingTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _poll(user.uid, user.householdId),
    );

    return HealthData(latestReadings: _latestReadings);
  }

  Future<void> _poll(String userId, String householdId) async {
    final fetchUseCase = ref.read(fetchHealthDataUseCaseProvider);
    final detectUseCase = ref.read(detectAnomaliesUseCaseProvider);
    final saveUseCase = ref.read(saveHealthEventUseCaseProvider);

    // Vitals: 30-minute window. Steps: 4-hour window for inactivity check.
    final vitalResult = await fetchUseCase(FetchHealthParams(
      userId: userId,
      types: [HealthReadingType.heartRate, HealthReadingType.bloodOxygen],
      window: const Duration(minutes: 30),
    ));
    final stepsResult = await fetchUseCase(FetchHealthParams(
      userId: userId,
      types: [HealthReadingType.steps],
      window: const Duration(hours: 4),
    ));

    final vitals = vitalResult.fold((_) => <HealthReading>[], (r) => r);
    final steps = stepsResult.fold((_) => <HealthReading>[], (r) => r);
    final all = [...vitals, ...steps];

    if (all.isEmpty) return;

    // Update latest reading per type
    for (final type in HealthReadingType.values) {
      final typed = all.where((r) => r.type == type).toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      if (typed.isNotEmpty) _latestReadings[type] = typed.first;
    }

    // Persist most-recent vitals (skip duplicates — Firestore doc overwrite is idempotent)
    for (final reading in vitals.take(5)) {
      await saveUseCase.saveReading(reading);
    }

    // Anomaly detection
    final anomalies = detectUseCase(
      readings: all,
      userId: userId,
      householdId: householdId,
    );

    HealthAnomaly? activeAnomaly;
    for (final anomaly in anomalies) {
      await saveUseCase.saveAnomaly(anomaly);
      if (anomaly.severity == AnomalySeverity.critical) activeAnomaly = anomaly;
    }

    state = AsyncData(
      HealthData(latestReadings: _latestReadings, activeAnomaly: activeAnomaly),
    );

    if (activeAnomaly != null) {
      await HealthMonitoringService.updateNotification(activeAnomaly.message);
    }
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncData(HealthLoading());
    await _poll(user.uid, user.householdId);
  }

  Future<void> requestPermissions() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final repo = ref.read(healthRepositoryProvider);
    await repo.requestHealthPermissions(_monitoredTypes);
    // Always re-run build so the UI reflects whatever the user granted
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final healthNotifierProvider =
    AsyncNotifierProvider<HealthNotifier, HealthState>(HealthNotifier.new);

// Anomalies stream — used by the monitor dashboard
final anomaliesProvider = StreamProvider.autoDispose
    .family<List<HealthAnomaly>, String>((ref, householdId) {
  final repo = ref.watch(healthRepositoryProvider);
  return repo
      .watchAnomalies(householdId: householdId)
      .map((e) => e.fold((_) => <HealthAnomaly>[], (list) => list));
});

// DI bridge providers — overridden in ProviderScope via get_it
final healthRepositoryProvider = Provider<HealthRepository>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final fetchHealthDataUseCaseProvider = Provider<FetchHealthDataUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final saveHealthEventUseCaseProvider = Provider<SaveHealthEventUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

// DetectAnomaliesUseCase has no external deps — no DI override needed
final detectAnomaliesUseCaseProvider = Provider<DetectAnomaliesUseCase>(
  (_) => const DetectAnomaliesUseCase(),
);
