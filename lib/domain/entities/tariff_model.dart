class TariffModel {
  final int storeId;
  final String wh;
  final int coef;
  final String type;
  const TariffModel({
    required this.storeId,
    required this.wh,
    required this.coef,
    required this.type,
  });

  bool isBoxes() {
    return type == 'b';
  }

  bool isMono() {
    return type == 'm';
  }
}
