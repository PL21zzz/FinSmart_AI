import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  static String formatShortDay(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else if (difference == -1) {
      return 'Ngày mai';
    } else {
      return formatFullDate(date);
    }
  }
}
