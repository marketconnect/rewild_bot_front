import 'dart:convert';

import 'package:hive/hive.dart';

part 'commission_model.g.dart';

@HiveType(typeId: 11)
class CommissionModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final double commission;

  @HiveField(4)
  final double fbs;

  @HiveField(5)
  final double fbo;

  CommissionModel({
    required this.id,
    required this.category,
    required this.subject,
    required this.commission,
    required this.fbs,
    required this.fbo,
  });

  CommissionModel copyWith({
    int? id,
    String? category,
    String? subject,
    double? commission,
    double? fbs,
    double? fbo,
  }) {
    return CommissionModel(
      id: id ?? this.id,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      commission: commission ?? this.commission,
      fbs: fbs ?? this.fbs,
      fbo: fbo ?? this.fbo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'subject': subject,
      'commission': commission,
      'fbs': fbs,
      'fbo': fbo,
    };
  }

  factory CommissionModel.fromMap(Map<String, dynamic> map) {
    return CommissionModel(
      id: map['id'] as int,
      category: map['category'] as String,
      subject: map['subject'] as String,
      commission: map['commission'] as double,
      fbs: map['fbs'] as double,
      fbo: map['fbo'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommissionModel.fromJson(String source) =>
      CommissionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommissionModel(id: $id, category: $category, subject: $subject, commission: $commission, fbs: $fbs, fbo: $fbo)';
  }

  @override
  bool operator ==(covariant CommissionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.category == category &&
        other.subject == subject &&
        other.commission == commission &&
        other.fbs == fbs &&
        other.fbo == fbo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        subject.hashCode ^
        commission.hashCode ^
        fbs.hashCode ^
        fbo.hashCode;
  }
}
