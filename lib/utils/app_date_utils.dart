import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Date helpers for the app. Named AppDateUtils to avoid clashing with
/// Flutter's material `DateUtils`.
class AppDateUtils {
  const AppDateUtils._();

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM d, y').format(date);
  }

  static String formatDateShort(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d').format(date);
  }

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Whole days from today (start-of-day) until [target] (start-of-day).
  /// Negative if [target] is in the past.
  static int daysUntil(DateTime target) {
    final today = startOfDay(DateTime.now());
    return startOfDay(target).difference(today).inDays;
  }

  static DateTime? timestampToDateTime(Timestamp? timestamp) =>
      timestamp?.toDate();

  static Timestamp? dateTimeToTimestamp(DateTime? dateTime) =>
      dateTime == null ? null : Timestamp.fromDate(dateTime);

  /// Formats a [DateTime] as the `yyyy-MM-dd` key used by water docs.
  static String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
