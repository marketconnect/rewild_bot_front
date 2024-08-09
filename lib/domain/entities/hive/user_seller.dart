import 'package:hive/hive.dart';

part 'user_seller.g.dart';

@HiveType(typeId: 8)
class UserSeller extends HiveObject {
  @HiveField(0)
  final String sellerId;

  @HiveField(1)
  String sellerName;

  @HiveField(2)
  final bool isActive;
  void updateName(String name) {
    sellerName = name;
  }

  UserSeller({
    required this.sellerId,
    required this.sellerName,
    required this.isActive,
  });
}
