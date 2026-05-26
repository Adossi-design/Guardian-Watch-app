import 'package:home_widget/home_widget.dart';

// Updates the iOS/Android home screen widget with the latest voice AI status.
// Platform widget layouts (AppWidgetProvider for Android, WidgetKit for iOS)
// are registered in the native project — see docs/home_widget_setup.md.
class HomeWidgetService {
  static const _appGroupId = 'group.com.guardianwatch.guardian_watch';
  static const _androidWidgetName = 'GuardianWatchWidget';
  static const _iosWidgetName = 'GuardianWatchWidget';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateLastResponse({
    required String response,
    required DateTime timestamp,
  }) async {
    await HomeWidget.saveWidgetData<String>('last_response', response);
    await HomeWidget.saveWidgetData<String>(
      'last_updated',
      _formatTime(timestamp),
    );
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iosWidgetName,
    );
  }

  static Future<void> updateStatus(String status) async {
    await HomeWidget.saveWidgetData<String>('status', status);
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iosWidgetName,
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
