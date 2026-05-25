import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// Called by the Android ForegroundService when it (re-)starts.
// The handler is notification-only; health polling runs in the main isolate
// via a Timer.periodic inside HealthNotifier. This keeps MethodChannel access
// (health package, Firebase) entirely in the main Dart isolate.
@pragma('vm:entry-point')
void startHealthMonitoringCallback() {
  FlutterForegroundTask.setTaskHandler(_NotificationTaskHandler());
}

class HealthMonitoringService {
  static const _channelId = 'guardian_health_monitoring';
  static const _serviceId = 1001;

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: 'Health Monitoring',
        channelDescription:
            'GuardianWatch is monitoring your health in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> startService({
    required String userId,
    required String householdId,
  }) async {
    await FlutterForegroundTask.saveData(key: 'userId', value: userId);
    await FlutterForegroundTask.saveData(key: 'householdId', value: householdId);

    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      notificationTitle: 'GuardianWatch Active',
      notificationText: 'Health monitoring is running',
      notificationIcon: null,
      callback: startHealthMonitoringCallback,
    );
  }

  static Future<void> stopService() => FlutterForegroundTask.stopService();

  static Future<void> updateNotification(String text) =>
      FlutterForegroundTask.updateService(
        notificationTitle: 'GuardianWatch Active',
        notificationText: text,
      );
}

// Minimal handler — keeps the foreground notification visible.
class _NotificationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}
