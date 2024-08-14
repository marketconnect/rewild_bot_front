// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserSeller {
  final String sellerId;

  String sellerName;

  final bool isActive;
  void updateName(String name) {
    sellerName = name;
  }

  UserSeller({
    required this.sellerId,
    required this.sellerName,
    required this.isActive,
  });

  // fromMap
  factory UserSeller.fromMap(Map<String, dynamic> map) {
    return UserSeller(
      sellerId: map['sellerId'] as String,
      sellerName: map['sellerName'] as String,
      isActive: map['isActive'] as bool,
    );
  }

  // copyWith
  UserSeller copyWith({
    String? sellerId,
    String? sellerName,
    bool? isActive,
  }) {
    return UserSeller(
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      isActive: isActive ?? this.isActive,
    );
  }

  // toMap

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sellerId': sellerId,
      'sellerName': sellerName,
      'isActive': isActive,
    };
  }

  String toJson() => json.encode(toMap());

  factory UserSeller.fromJson(String source) =>
      UserSeller.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserSeller(sellerId: $sellerId, sellerName: $sellerName, isActive: $isActive)';

  @override
  bool operator ==(covariant UserSeller other) {
    if (identical(this, other)) return true;

    return other.sellerId == sellerId &&
        other.sellerName == sellerName &&
        other.isActive == isActive;
  }

  @override
  int get hashCode =>
      sellerId.hashCode ^ sellerName.hashCode ^ isActive.hashCode;
}
