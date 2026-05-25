import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/emergency_incident.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/cancel_emergency_usecase.dart';
import '../../domain/usecases/resolve_emergency_usecase.dart';
import '../../domain/usecases/trigger_emergency_usecase.dart';
import '../../services/emergency_notification_service.dart';
import '../../services/fall_detection_service.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class EmergencyState {
  const EmergencyState();
}

final class EmergencyIdle extends EmergencyState {
  const EmergencyIdle();
}

final class EmergencyCountdownState extends EmergencyState {
  const EmergencyCountdownState({
    required this.secondsRemaining,
    required this.incident,
  });
  final int secondsRemaining;
  final EmergencyIncident incident;
}

final class EmergencyActiveState extends EmergencyState {
  const EmergencyActiveState(this.incident);
  final EmergencyIncident incident;
}

final class EmergencyResolvedState extends EmergencyState {
  const EmergencyResolvedState(this.incident);
  final EmergencyIncident incident;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class EmergencyNotifier extends AsyncNotifier<EmergencyState> {
  static const _countdownSeconds = 30;

  Timer? _countdownTimer;
  FallDetectionService? _fallDetection;

  @override
  Future<EmergencyState> build() async {
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _fallDetection?.dispose();
    });

    final user = ref.watch(currentUserProvider);
    if (user == null) return const EmergencyIdle();

    // Start fall detection — runs continuously while user is authenticated
    _fallDetection = FallDetectionService(
      onFallDetected: () =>
          triggerEmergency(EmergencyTriggerType.fallDetected),
    );
    _fallDetection!.start();

    return const EmergencyIdle();
  }

  // Called by SOS button, voice activation (Phase 5), or fall detection
  Future<void> triggerEmergency(EmergencyTriggerType type) async {
    // Idempotent — don't stack emergencies
    final current = state.valueOrNull;
    if (current is EmergencyCountdownState || current is EmergencyActiveState) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final useCase = ref.read(triggerEmergencyUseCaseProvider);
    final result = await useCase(
      userId: user.uid,
      householdId: user.householdId,
      triggerType: type,
      userName: user.name,
    );

    result.fold(
      (_) {/* silent — don't block the user on a network error */},
      (incident) {
        _startCountdown(incident);
        EmergencyNotificationService.showCountdownAlert();
      },
    );
  }

  void _startCountdown(EmergencyIncident incident) {
    int secondsLeft = _countdownSeconds;
    state = AsyncData(EmergencyCountdownState(
      secondsRemaining: secondsLeft,
      incident: incident,
    ));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        t.cancel();
        _activateEmergency(incident);
      } else {
        state = AsyncData(EmergencyCountdownState(
          secondsRemaining: secondsLeft,
          incident: incident,
        ));
      }
    });
  }

  Future<void> _activateEmergency(EmergencyIncident incident) async {
    final repo = ref.read(emergencyRepositoryProvider);
    await repo.updateStatus(
      incidentId: incident.id,
      status: EmergencyStatus.active,
    );

    final activeIncident = EmergencyIncident(
      id: incident.id,
      userId: incident.userId,
      householdId: incident.householdId,
      triggerType: incident.triggerType,
      status: EmergencyStatus.active,
      startedAt: incident.startedAt,
      userName: incident.userName,
    );

    state = AsyncData(EmergencyActiveState(activeIncident));

    // Cloud Function watches /emergency_incidents and fires FCM multicast
    // when status flips to 'active'.
    await EmergencyNotificationService.showEmergencyAlert(
      incident.userName ?? 'Guardian',
    );
  }

  // Called by the countdown page widget when its internal timer fires,
  // ensuring whichever timer (widget or notifier) fires first wins.
  Future<void> activateNow(EmergencyIncident incident) async {
    _countdownTimer?.cancel();
    await _activateEmergency(incident);
  }

  // Primary user taps "I AM OK" during countdown
  Future<void> cancelCountdown() async {
    final current = state.valueOrNull;
    if (current is! EmergencyCountdownState) return;
    _countdownTimer?.cancel();

    final useCase = ref.read(cancelEmergencyUseCaseProvider);
    await useCase(current.incident.id);
    await EmergencyNotificationService.cancelAll();
    state = const AsyncData(EmergencyIdle());
  }

  // Primary user marks emergency resolved from the active screen
  Future<void> resolveEmergency() async {
    final current = state.valueOrNull;
    if (current is! EmergencyActiveState) return;

    final useCase = ref.read(resolveEmergencyUseCaseProvider);
    await useCase.resolve(current.incident.id);
    await EmergencyNotificationService.cancelAll();
    state = AsyncData(EmergencyResolvedState(current.incident));

    // Auto-reset after brief confirmation
    Future.delayed(const Duration(seconds: 3), () {
      if (state.valueOrNull is EmergencyResolvedState) {
        state = const AsyncData(EmergencyIdle());
      }
    });
  }

  // Monitor acknowledges the emergency from the monitor dashboard
  Future<void> acknowledgeEmergency({
    required String incidentId,
    required String acknowledgedBy,
  }) async {
    final useCase = ref.read(resolveEmergencyUseCaseProvider);
    await useCase.acknowledge(
      incidentId: incidentId,
      acknowledgedBy: acknowledgedBy,
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final emergencyNotifierProvider =
    AsyncNotifierProvider<EmergencyNotifier, EmergencyState>(
  EmergencyNotifier.new,
);

// Active incidents stream for monitor dashboard
final activeIncidentsProvider =
    StreamProvider.autoDispose.family<List<EmergencyIncident>, String>(
  (ref, householdId) {
    final repo = ref.watch(emergencyRepositoryProvider);
    return repo
        .watchActiveIncidents(householdId: householdId)
        .map((e) => e.fold((_) => <EmergencyIncident>[], (list) => list));
  },
);

// DI bridge providers
final emergencyRepositoryProvider = Provider<EmergencyRepository>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final triggerEmergencyUseCaseProvider = Provider<TriggerEmergencyUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final cancelEmergencyUseCaseProvider = Provider<CancelEmergencyUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final resolveEmergencyUseCaseProvider = Provider<ResolveEmergencyUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);
