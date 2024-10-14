class UserProductCard {
  final int sku;
  final String img;
  final int subjectId;
  final String mp;
  final String name;
  final double? totalCost;

  UserProductCard({
    required this.sku,
    required this.img,
    required this.subjectId,
    required this.mp,
    required this.name,
    this.totalCost,
  });

  // Преобразование из Map для записи в базу данных
  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'img': img,
      'subject_id': subjectId,
      'mp': mp,
      'name': name,
      'sku_mp': '${sku}_$mp',
    };
  }

  factory UserProductCard.fromMap(Map<String, dynamic> map) {
    return UserProductCard(
      sku: map['sku'],
      img: map['img'],
      subjectId: map['subject_id'],
      mp: map['mp'],
      name: map['name'],
    );
  }
}
