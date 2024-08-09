import 'package:hive/hive.dart';

part 'rewild_notification_model.g.dart';

@HiveType(typeId: 10)
class ReWildNotificationModel {
  @HiveField(0)
  int parentId;

  @HiveField(1)
  int condition;

  @HiveField(2)
  String value;

  @HiveField(3)
  int? sizeId;

  @HiveField(4)
  int? wh;

  @HiveField(5)
  bool reusable;

  ReWildNotificationModel({
    required this.parentId,
    required this.condition,
    required this.value,
    this.sizeId,
    this.wh,
    this.reusable = false,
  });

  ReWildNotificationModel copyWith({
    int? parentId,
    int? condition,
    String? value,
    int? sizeId,
    int? wh,
    bool? reusable,
  }) {
    return ReWildNotificationModel(
      parentId: parentId ?? this.parentId,
      condition: condition ?? this.condition,
      value: value ?? this.value,
      sizeId: sizeId ?? this.sizeId,
      wh: wh ?? this.wh,
      reusable: reusable ?? this.reusable,
    );
  }

  @override
  String toString() {
    return 'ReWildNotificationModel(parentId: $parentId, condition: $condition, value: $value, sizeId: $sizeId, wh: $wh, reusable: $reusable)';
  }

  @override
  bool operator ==(covariant ReWildNotificationModel other) {
    if (identical(this, other)) return true;

    return other.parentId == parentId &&
        other.condition == condition &&
        other.value == value &&
        other.sizeId == sizeId &&
        other.wh == wh &&
        other.reusable == reusable;
  }

  @override
  int get hashCode {
    return parentId.hashCode ^
        condition.hashCode ^
        value.hashCode ^
        sizeId.hashCode ^
        wh.hashCode ^
        reusable.hashCode;
  }
}
