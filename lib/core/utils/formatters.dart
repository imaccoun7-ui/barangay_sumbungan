import 'package:intl/intl.dart';

/// Date/time helpers used by report, document and notification screens.
class Formatters {
  Formatters._();

  static final DateFormat _monthDay = DateFormat('MMM d, y');
  static final DateFormat _fullDate = DateFormat('MMMM d, y');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dateTime = DateFormat('MMM d, y · h:mm a');
  static final DateFormat _monthDayShort = DateFormat('MMM d');

  static String date(DateTime value) => _monthDay.format(value);
  static String fullDate(DateTime value) => _fullDate.format(value);
  static String time(DateTime value) => _time.format(value);
  static String dateTime(DateTime value) => _dateTime.format(value);
  static String shortDay(DateTime value) => _monthDayShort.format(value);

  /// "Today · 9:03 AM", "Yesterday · 4:20 PM" or "Feb 18 · 2:15 PM".
  static String relative(DateTime value) {
    final DateTime now = DateTime.now();
    final DateTime day = DateTime(value.year, value.month, value.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int difference = today.difference(day).inDays;
    if (difference == 0) return 'Today · ${time(value)}';
    if (difference == 1) return 'Yesterday · ${time(value)}';
    return '${shortDay(value)} · ${time(value)}';
  }

  static String greeting(DateTime now) {
    final int hour = now.hour;
    if (hour < 12) return 'Magandang umaga';
    if (hour < 18) return 'Magandang hapon';
    return 'Magandang gabi';
  }
}
