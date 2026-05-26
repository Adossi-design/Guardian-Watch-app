import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'app/di/injection_container.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_provider.dart';
import 'features/emergency/domain/repositories/emergency_repository.dart';
import 'features/emergency/domain/usecases/cancel_emergency_usecase.dart';
import 'features/emergency/domain/usecases/resolve_emergency_usecase.dart';
import 'features/emergency/domain/usecases/trigger_emergency_usecase.dart';
import 'features/emergency/presentation/bloc/emergency_provider.dart';
import 'features/emergency/services/emergency_notification_service.dart';
import 'features/geofencing/domain/repositories/geofence_repository.dart';
import 'features/geofencing/domain/usecases/create_geofence_zone_usecase.dart';
import 'features/geofencing/domain/usecases/delete_geofence_zone_usecase.dart';
import 'features/geofencing/domain/usecases/record_breach_usecase.dart';
import 'features/geofencing/domain/usecases/update_location_usecase.dart';
import 'features/geofencing/presentation/bloc/geofence_provider.dart';
import 'features/health_monitoring/domain/repositories/health_repository.dart';
import 'features/voice_ai/domain/repositories/voice_repository.dart';
import 'features/voice_ai/domain/usecases/save_voice_session_usecase.dart';
import 'features/voice_ai/presentation/bloc/voice_provider.dart';
import 'features/health_monitoring/domain/usecases/fetch_health_data_usecase.dart';
import 'features/health_monitoring/domain/usecases/save_health_event_usecase.dart';
import 'features/health_monitoring/presentation/bloc/health_provider.dart';
import 'features/health_monitoring/services/health_monitoring_service.dart';
import 'features/multi_device/data/datasources/invite_datasource.dart';
import 'features/multi_device/presentation/bloc/invite_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required by flutter_foreground_task — must be called before runApp
  FlutterForegroundTask.initCommunicationPort();

  // Health monitoring foreground service notification options
  HealthMonitoringService.init();

  // Lock to portrait — medical safety, per spec
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive local storage
  await Hive.initFlutter();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase App Check — debug provider in dev, production providers in release
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );

  // Crashlytics — forward all Flutter errors in production only
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Injectable dependency injection
  await configureDependencies();

  // Emergency local notifications channel
  await EmergencyNotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Bridge get_it singletons into the Riverpod provider graph
        authRepositoryProvider.overrideWithValue(sl<AuthRepository>()),
        inviteDataSourceProvider.overrideWithValue(sl<InviteDataSource>()),
        healthRepositoryProvider.overrideWithValue(sl<HealthRepository>()),
        fetchHealthDataUseCaseProvider
            .overrideWithValue(sl<FetchHealthDataUseCase>()),
        saveHealthEventUseCaseProvider
            .overrideWithValue(sl<SaveHealthEventUseCase>()),
        emergencyRepositoryProvider
            .overrideWithValue(sl<EmergencyRepository>()),
        triggerEmergencyUseCaseProvider
            .overrideWithValue(sl<TriggerEmergencyUseCase>()),
        cancelEmergencyUseCaseProvider
            .overrideWithValue(sl<CancelEmergencyUseCase>()),
        resolveEmergencyUseCaseProvider
            .overrideWithValue(sl<ResolveEmergencyUseCase>()),
        geofenceRepositoryProvider
            .overrideWithValue(sl<GeofenceRepository>()),
        createGeofenceZoneUseCaseProvider
            .overrideWithValue(sl<CreateGeofenceZoneUseCase>()),
        deleteGeofenceZoneUseCaseProvider
            .overrideWithValue(sl<DeleteGeofenceZoneUseCase>()),
        updateLocationUseCaseProvider
            .overrideWithValue(sl<UpdateLocationUseCase>()),
        recordBreachUseCaseProvider
            .overrideWithValue(sl<RecordBreachUseCase>()),
        voiceRepositoryProvider
            .overrideWithValue(sl<VoiceRepository>()),
        saveVoiceSessionUseCaseProvider
            .overrideWithValue(sl<SaveVoiceSessionUseCase>()),
      ],
      child: const GuardianWatchApp(),
    ),
  );
}
