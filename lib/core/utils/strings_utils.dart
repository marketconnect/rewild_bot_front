import 'dart:math';

String getNoun(int number, String one, String two, String five) {
  int n = number.abs() % 100;

  if (n >= 5 && n <= 20) {
    return five;
  }

  n %= 10;

  if (n == 1) {
    return one;
  }

  if (n >= 2 && n <= 4) {
    return two;
  }

  return five;
}

String getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

// String escapeSpecialChars(String input) {
//   return input
//       .replaceAll("'", "\\'")
//       .replaceAll('"', '\\"')
//       .replaceAll('&', '&amp;')
//       .replaceAll('<', '&lt;')
//       .replaceAll('>', '&gt;');
// }

String removeEdgeQuotes(String input) {
  if (input.isEmpty) return input;

  if (input.startsWith('"') && input.endsWith('"')) {
    return input.substring(1, input.length - 1);
  } else if (input.startsWith('"')) {
    return input.substring(1);
  } else if (input.endsWith('"')) {
    return input.substring(0, input.length - 1);
  }

  return input;
}
