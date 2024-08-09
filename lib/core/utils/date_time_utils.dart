import 'package:intl/intl.dart';

String toIso8601StringNow() {
  return DateTime.now().toIso8601String();
}

bool areTheSameDates(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

DateTime fromIso8601String(String iso8601String) {
  return DateTime.tryParse(iso8601String) ?? DateTime.now();
}

int getMonthAgoTimestamp() {
  DateTime nowDate = DateTime.now();
  DateTime monthAgo = DateTime(nowDate.year, nowDate.month - 1, nowDate.day,
      nowDate.hour, nowDate.minute, nowDate.second);
  return monthAgo.millisecondsSinceEpoch ~/ 1000;
}

int getNowTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

DateTime yesterdayEndOfTheDay() {
  DateTime now = DateTime.now();

  final dateFrom = now.subtract(Duration(
    hours: now.hour,
    minutes: now.minute,
    seconds: now.second + 5,
    milliseconds: now.millisecond,
    microseconds: now.microsecond,
  ));
  return dateFrom;
}

String formatReviewDate(DateTime createdAt) {
  return DateTime.now().day == createdAt.day
      ? '${createdAt.toLocal().hour.toString().padLeft(2, '0')}:${createdAt.toLocal().minute.toString().padLeft(2, '0')}'
      : '${createdAt.day}.${createdAt.month}.${createdAt.year}';
}

String formatDateForAnaliticsDetail(DateTime dateTime) {
  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(dateTime);
}

String formatDate(String dateString) {
  // Parse the input date string into a DateTime object
  DateTime dateTime = DateTime.parse(dateString);

  // Format the DateTime object into the desired output format
  String formattedDate =
      "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";

  return formattedDate;
}

String formatYYYYMMDD(DateTime date) {
  // DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(date);
  return formattedDate;
}

String formatMMDDMMMYYY(DateTime date) {
  // DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd.MM.yyyy').format(date);
  return formattedDate;
}

// 2020-02-25T03 to 25.02.2020
String convertDateTime(String inputPattern) {
  // Assuming the inputPattern is something like "2024-02-26T03"
  // First, remove the 'T' and anything after it, as it's not needed for this conversion
  String datePart = inputPattern.split('T')[0];

  // Parse the string to DateTime
  DateTime dateTime = DateTime.parse(datePart);

  // Format the DateTime to "dd-MM-yyyy"
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

  return formattedDate;
}

String formatLocalDateTime(DateTime utcDate, String locale) {
  final DateTime localDate = utcDate.toLocal();

  final DateFormat formatter = DateFormat.yMMMMd(locale).add_Hms();
  return formatter.format(localDate);
}

String formatDateForMycard(DateTime date) {
  final DateFormat formatter = DateFormat.yMMMMd('ru');
  return formatter.format(date);
}

bool isToday(DateTime? updatedAt) {
  if (updatedAt == null) {
    return false;
  }
  final DateTime today = DateTime.now();
  return updatedAt.day == today.day &&
      updatedAt.month == today.month &&
      updatedAt.year == today.year;
}

class DateSundaysCalculator {
  final DateTime _now = DateTime.now();

  DateTime get to {
    // Calculate last Sunday
    int daysSinceLastSunday = _now.weekday;
    return _now.subtract(Duration(days: daysSinceLastSunday));
  }

  DateTime get from {
    // Calculate the Sunday before the last Sunday
    return to.subtract(const Duration(days: 7));
  }
}

String getMonthFromOrderNumber(int orderNumber) {
  DateTime now = DateTime.now();
  final monthDate = DateTime(now.year, orderNumber, 1);

  // Использование DateFormat для получения названия месяца
  DateFormat formatter =
      DateFormat('MMMM', 'ru'); // 'MMMM' для полного названия месяца

  return formatter.format(monthDate);
}

String getWeekFromOrderNumber(int orderNumber) {
  DateTime now = DateTime.now();

  DateTime startDate =
      DateTime(now.year, 1, 1).add(Duration(days: (orderNumber - 1) * 7));

  startDate = DateTime(
      startDate.year, startDate.month, startDate.day - startDate.weekday + 1);

  DateTime endDate = startDate.add(const Duration(days: 6));

  // Форматируем даты в формате dd.MM
  String startDateFormatted = DateFormat('dd.MM').format(startDate);
  String endDateFormatted = DateFormat('dd.MM').format(endDate);

  // Возвращаем период от начала до конца недели
  return '$startDateFormatted - $endDateFormatted';
}
