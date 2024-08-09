extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return '';
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String take(int nbChars) => substring(0, nbChars.clamp(0, length));

  bool isWildberriesDetailUrl() {
    final regex =
        RegExp(r'^https:\/\/www\.wildberries\.ru\/catalog\/\d+\/detail\.aspx');
    return regex.hasMatch(this);
  }
}
