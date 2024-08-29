class TextFieldValidator {
  static bool isNumericAndGreaterThanN(String text, int n) {
    if (text.isEmpty) {
      return false; // Empty or null string is not numeric and not greater than 100
    }
    try {
      int value = int.parse(text);
      return value >= n;
    } catch (e) {
      return false; // If parsing fails, it's not numeric
    }
  }

  static bool isNotEmpty(String text, int n) {
    if (text.isEmpty) {
      return false; // Empty or null string is not numeric and not greater than 100
    }
    return true;
  }
}
