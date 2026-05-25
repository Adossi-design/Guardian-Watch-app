import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// High-priority local notifications for emergency events.
// Firebase FCM notifications for monitors are handled server-side
// via the Cloud Function in functions/src/index.ts.
class EmergencyNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'guardian_emergency';
  static const _countdownId = 9001;
  static const _alertId = 9002;

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            'Emergency Alerts',
            description:
                'Critical emergency notifications — do not disable.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
  }

  static Future<void> showCountdownAlert() async {
    await _plugin.show(
      _countdownId,
      '⚠️ Emergency starting',
      'Tap "I AM OK" in the app to cancel.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Emergency Alerts',
          importance: Importance.max,
          priority: Priority.max,
          ongoing: true,
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  static Future<void> showEmergencyAlert(String userName) async {
    await _plugin.cancel(_countdownId);
    await _plugin.show(
      _alertId,
      '🚨 Emergency activated',
      '$userName has triggered an emergency. Monitors are being notified.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Emergency Alerts',
          importance: Importance.max,
          priority: Priority.max,
          ongoing: true,
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
