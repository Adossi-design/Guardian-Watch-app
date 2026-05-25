import 'package:intl/intl.dart';

abstract final class GuardianDateUtils {
  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  static String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);
  static String formatDate(DateTime dt) => DateFormat('MMM d, y').format(dt);
  static String formatDateTime(DateTime dt) => DateFormat('MMM d, y • HH:mm').format(dt);
  static String formatShortDate(DateTime dt) => DateFormat('MMM d').format(dt);

  static bool isNightTime(DateTime dt) {
    final hour = dt.hour;
    return hour >= 22 || hour < 6;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  static DateTime endOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
}
