extension DateTimeExtensions on DateTime {
  bool isIntraday() {
    DateTime now = DateTime.now();

    if (year == now.year && month == now.month && day == now.day) {
      if (isAfter(DateTime(now.year, now.month, now.day)) &&
          isBefore(DateTime(now.year, now.month, now.day + 1))) {
        return true;
      }
    }

    return false;
  }

  DateTime getStartOfDay() {
    return DateTime(year, month, day);
  }

  DateTime getEndOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  String formatDateTime() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime dayBeforeYesterday = DateTime(now.year, now.month, now.day - 2);

    if (isAfter(today)) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else if (isAfter(yesterday)) {
      return 'Вчера';
    } else if (isAfter(dayBeforeYesterday)) {
      return '2 дня назад';
    } else {
      return '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
    }
  }

  DateTime getMidnight() {
    return DateTime(year, month, day, 0, 1);
  }

  String formatDate([bool? dropTime]) {
    var m = month.toString().padLeft(2, '0');
    var d = day.toString().padLeft(2, '0');
    var h = hour.toString().padLeft(2, '0');
    var mi = minute.toString().padLeft(2, '0');
    if (dropTime != null && dropTime) {
      return '$d.$m.$year';
    }
    return '$d.$m.$year $h:$mi';
  }
}
