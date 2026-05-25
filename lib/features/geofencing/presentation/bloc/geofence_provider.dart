import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../emergency/domain/entities/emergency_incident.dart';
import '../../../emergency/presentation/bloc/emergency_provider.dart';
import '../../domain/entities/geofence_breach.dart';
import '../../domain/entities/geofence_zone.dart';
import '../../domain/entities/location_reading.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../../domain/usecases/create_geofence_zone_usecase.dart';
import '../../domain/usecases/delete_geofence_zone_usecase.dart';
import '../../domain/usecases/record_breach_usecase.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../services/geofence_monitoring_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class GeofenceState {
  const GeofenceState();
}

final class GeofenceInitial extends GeofenceState {
  const GeofenceInitial();
}

final class GeofencePermissionRequired extends GeofenceState {
  const GeofencePermissionRequired();
}

final class GeofenceData extends GeofenceState {
  const GeofenceData({
    required this.zones,
    required this.recentBreaches,
    this.currentLocation,
    this.isMonitoring = false,
  });

  final List<GeofenceZone> zones;
  final List<GeofenceBreach> recentBreaches;
  final LocationReading? currentLocation;
  final bool isMonitoring;

  GeofenceData copyWith({
    List<GeofenceZone>? zones,
    List<GeofenceBreach>? recentBreaches,
    LocationReading? currentLocation,
    bool? isMonitoring,
  }) =>
      GeofenceData(
        zones: zones ?? this.zones,
        recentBreaches: recentBreaches ?? this.recentBreaches,
        currentLocation: currentLocation ?? this.currentLocation,
        isMonitoring: isMonitoring ?? this.isMonitoring,
      );
}

final class GeofenceError extends GeofenceState {
  const GeofenceError(this.message);
  final String message;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GeofenceNotifier extends AsyncNotifier<GeofenceState> {
  static const _uuid = Uuid();

  GeofenceMonitoringService? _monitor;
  StreamSubscription<dynamic>? _zonesSub;
  StreamSubscription<dynamic>? _breachesSub;

  @override
  Future<GeofenceState> build() async {
    ref.onDispose(() {
      _monitor?.dispose();
      _zonesSub?.cancel();
      _breachesSub?.cancel();
    });

    final user = ref.watch(currentUserProvider);
    if (user == null) return const GeofenceInitial();

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const GeofencePermissionRequired();
    }

    final repo = ref.read(geofenceRepositoryProvider);
    List<GeofenceZone> zones = [];
    List<GeofenceBreach> breaches = [];

    // Subscribe to zones
    _zonesSub = repo.watchZones(user.householdId).listen((either) {
      either.fold((_) {}, (z) {
        zones = z;
        _monitor?.updateZones(z);
        _updateData((d) => d.copyWith(zones: z));
      });
    });

    // Subscribe to recent breach events
    _breachesSub = repo.watchBreaches(user.householdId).listen((either) {
      either.fold((_) {}, (b) {
        breaches = b;
        _updateData((d) => d.copyWith(recentBreaches: b));
      });
    });

    // Start monitoring only for primary role
    if (user.role.name == 'primary') {
      _monitor = GeofenceMonitoringService(
        userId: user.uid,
        householdId: user.householdId,
        onLocationUpdate: _onLocationUpdate,
        onBreach: _onBreach,
        onWanderingDetected: _onWanderingDetected,
      );
      _monitor!.start(zones);
    }

    return GeofenceData(
      zones: zones,
      recentBreaches: breaches,
      isMonitoring: user.role.name == 'primary',
    );
  }

  void _updateData(GeofenceData Function(GeofenceData) updater) {
    final current = state.valueOrNull;
    if (current is GeofenceData) {
      state = AsyncData(updater(current));
    }
  }

  void _onLocationUpdate(LocationReading reading) {
    _updateData((d) => d.copyWith(currentLocation: reading));
    // Fire-and-forget — errors are non-fatal
    ref
        .read(updateLocationUseCaseProvider)
        .call(reading)
        .ignore();
  }

  void _onBreach(GeofenceBreach breach) {
    ref.read(recordBreachUseCaseProvider).call(breach).ignore();
  }

  void _onWanderingDetected() {
    ref.read(emergencyNotifierProvider.notifier).triggerEmergency(
          EmergencyTriggerType.healthAnomaly,
        );
  }

  // Called by primary user — request permission then restart
  Future<void> requestPermission() async {
    final status = await Geolocator.requestPermission();
    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      ref.invalidateSelf();
    }
  }

  Future<void> createZone({
    required String name,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final zone = GeofenceZone(
      id: _uuid.v4(),
      householdId: user.householdId,
      name: name,
      centerLat: centerLat,
      centerLng: centerLng,
      radiusMeters: radiusMeters,
      createdAt: DateTime.now(),
      createdBy: user.uid,
    );

    await ref.read(createGeofenceZoneUseCaseProvider).call(zone);
  }

  Future<void> deleteZone(String zoneId) async {
    await ref.read(deleteGeofenceZoneUseCaseProvider).call(zoneId);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final geofenceNotifierProvider =
    AsyncNotifierProvider<GeofenceNotifier, GeofenceState>(
  GeofenceNotifier.new,
);

// Watch live location of another user (monitor side)
final liveLocationProvider =
    StreamProvider.autoDispose.family<LocationReading?, String>(
  (ref, userId) {
    final repo = ref.watch(geofenceRepositoryProvider);
    return repo
        .watchLiveLocation(userId)
        .map((e) => e.fold((_) => null, (l) => l));
  },
);

// DI bridge providers
final geofenceRepositoryProvider = Provider<GeofenceRepository>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final createGeofenceZoneUseCaseProvider =
    Provider<CreateGeofenceZoneUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final deleteGeofenceZoneUseCaseProvider =
    Provider<DeleteGeofenceZoneUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final updateLocationUseCaseProvider = Provider<UpdateLocationUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final recordBreachUseCaseProvider = Provider<RecordBreachUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);
