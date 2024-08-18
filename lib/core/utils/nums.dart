import 'package:fixnum/fixnum.dart';

Int64 stringToInt64(String stringValue) {
  try {
    if (stringValue.isEmpty) {
      return Int64(0);
    }
    final intValue = int.tryParse(stringValue);
    final int64Value = Int64(intValue!);
    return int64Value;
  } catch (e) {
    return Int64(0);
  }
}

int unixTimestamp2019() {
  try {
    final DateTime dateTime = DateTime(2019, 1, 1);
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  } catch (e) {
    return 0;
  }
}

int checkNumberType(String input) {
  if (int.tryParse(input) != null) {
    return 0; // It's an integer
  } else if (double.tryParse(input) != null) {
    return 1; // It's a double
  } else {
    return -1; // It's neither an integer nor a double
  }
}
