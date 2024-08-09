// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ApiKeyModel {
  final String token;
  final String type;
  final String sellerId;
  final DateTime expiryDate;
  final String tokenReadOrWrite;

  bool isSelected = false;
  void toggleSelected() {
    isSelected = !isSelected;
  }

  ApiKeyModel({
    required this.token,
    required this.type,
    required this.expiryDate,
    required this.tokenReadOrWrite,
    this.sellerId = '',
  });

  ApiKeyModel copyWith({
    String? token,
    String? type,
    String? sellerId,
    String? sellerName,
    DateTime? expiryDate,
    String? tokenReadOrWrite,
  }) {
    return ApiKeyModel(
      token: token ?? this.token,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      sellerId: sellerId ?? this.sellerId,
      tokenReadOrWrite: tokenReadOrWrite ?? this.tokenReadOrWrite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'type': type,
      'expiryDate': expiryDate.toIso8601String(),
      'tokenReadOrWrite': tokenReadOrWrite,
      'userId': sellerId,
    };
  }

  factory ApiKeyModel.fromMap(Map<String, dynamic> map) {
    return ApiKeyModel(
      token: map['token'] as String,
      type: map['type'] as String,
      sellerId: map['userId'] as String,
      tokenReadOrWrite: map['tokenReadOrWrite'] as String,
      expiryDate: DateTime.parse(map['expiryDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiKeyModel.fromJson(String source) =>
      ApiKeyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ApiKeyModel(token: $token, type: $type, isSelected: $isSelected, userId: $sellerId, expiryDate: $expiryDate, tokenReadOrWrite: $tokenReadOrWrite)';

  @override
  bool operator ==(covariant ApiKeyModel other) {
    if (identical(this, other)) return true;

    return other.token == token &&
        other.type == type &&
        other.expiryDate == expiryDate &&
        other.tokenReadOrWrite == tokenReadOrWrite &&
        other.isSelected == isSelected &&
        other.sellerId == sellerId;
  }

  @override
  int get hashCode => token.hashCode ^ type.hashCode;
}
