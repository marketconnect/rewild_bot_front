class Income {
  final int incomeId;
  final String number;
  final DateTime date;
  final DateTime lastChangeDate;
  final String supplierArticle;
  final String techSize;
  final String barcode;
  final int quantity;
  final double totalPrice;
  final DateTime dateClose;
  final String warehouseName;
  final int nmId;
  final String status;

  Income({
    required this.incomeId,
    required this.number,
    required this.date,
    required this.lastChangeDate,
    required this.supplierArticle,
    required this.techSize,
    required this.barcode,
    required this.quantity,
    required this.totalPrice,
    required this.dateClose,
    required this.warehouseName,
    required this.nmId,
    required this.status,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      incomeId: json['incomeId'],
      number: json['number'] ?? "",
      date: DateTime.parse(json['date']),
      lastChangeDate: DateTime.parse(json['lastChangeDate']),
      supplierArticle: json['supplierArticle'],
      techSize: json['techSize'],
      barcode: json['barcode'],
      quantity: json['quantity'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      dateClose: DateTime.parse(json['dateClose']),
      warehouseName: json['warehouseName'],
      nmId: json['nmId'],
      status: json['status'],
    );
  }
}
