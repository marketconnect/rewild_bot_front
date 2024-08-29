import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/advert_nm.dart';

class AdvertCatalogueModel extends Advert {
  List<AdvertCatalogueParam>? params;

  AdvertCatalogueModel({
    required super.campaignId,
    required super.name,
    required super.endTime,
    required super.createTime,
    required super.changeTime,
    required super.startTime,
    required super.dailyBudget,
    required super.status,
    required super.type,
    this.params,
  });

  factory AdvertCatalogueModel.fromJson(Map<String, dynamic> json) {
    return AdvertCatalogueModel(
      endTime: DateTime.parse(json['endTime']),
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      name: json['name'],
      params: json['params'] != null
          ? List<AdvertCatalogueParam>.from(json['params']
              .map((param) => AdvertCatalogueParam.fromJson(param)))
          : null,
      dailyBudget: json['dailyBudget'],
      campaignId: json['advertId'],
      status: json['status'],
      type: json['type'],
    );
  }

  @override
  String toString() =>
      'AdvertCatalogueModel(campaignId: $campaignId, name: $name, endTime: $endTime, createTime: $createTime, changeTime: $changeTime, startTime: $startTime, dailyBudget: $dailyBudget, status: $status, type: $type)';
}

class AdvertCatalogueParam {
  String? menuName;
  List<AdvertNm>? nms;
  int? menuId;
  int? price;

  AdvertCatalogueParam({
    this.menuName,
    this.nms,
    this.menuId,
    this.price,
  });

  factory AdvertCatalogueParam.fromJson(Map<String, dynamic> json) {
    return AdvertCatalogueParam(
      menuName: json['menuName'],
      nms: json['nms'] != null
          ? List<AdvertNm>.from(json['nms'].map((nm) => AdvertNm.fromJson(nm)))
          : null,
      menuId: json['menuId'],
      price: json['price'],
    );
  }
}
