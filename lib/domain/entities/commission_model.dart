// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CommissionModel {
  final int id;
  final String category;
  final String subject;
  final double commission;
  final double fbs;
  final double fbo;

  CommissionModel(
      {required this.id,
      required this.category,
      required this.subject,
      required this.commission,
      required this.fbs,
      required this.fbo});

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
