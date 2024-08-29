import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/advert_nm.dart';

class AdvertCardModel extends Advert {
  List<AdvertCardParam>? params;

  AdvertCardModel({
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

  factory AdvertCardModel.fromJson(Map<String, dynamic> json) {
    return AdvertCardModel(
      endTime: DateTime.parse(json['endTime']),
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      name: json['name'],
      params: json['params'] != null
          ? List<AdvertCardParam>.from(
              json['params'].map((param) => AdvertCardParam.fromJson(param)))
          : null,
      dailyBudget: json['dailyBudget'],
      campaignId: json['advertId'],
      status: json['status'],
      type: json['type'],
    );
  }

  @override
  String toString() =>
      'AdvertCardModel(campaignId: $campaignId, name: $name, endTime: $endTime, createTime: $createTime, changeTime: $changeTime, startTime: $startTime, dailyBudget: $dailyBudget, status: $status, type: $type)';
}

class AdvertCardParam {
  String? setName;
  List<AdvertNm>? nms;
  int? setId;
  int? price;

  AdvertCardParam({
    this.setName,
    this.nms,
    this.setId,
    this.price,
  });

  factory AdvertCardParam.fromJson(Map<String, dynamic> json) {
    return AdvertCardParam(
      setName: json['setName'],
      nms: json['nms'] != null
          ? List<AdvertNm>.from(json['nms'].map((nm) => AdvertNm.fromJson(nm)))
          : null,
      setId: json['setId'],
      price: json['price'],
    );
  }
}
