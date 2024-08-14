// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:rewild_bot_front/domain/entities/advert_base.dart';

class AdvertAutoModel extends Advert {
  AdvertAutoParams? autoParams;

  AdvertAutoModel({
    required super.campaignId,
    required super.name,
    required super.endTime,
    required super.createTime,
    required super.changeTime,
    required super.startTime,
    required super.dailyBudget,
    required super.status,
    required super.type,
    required this.autoParams,
  });

  factory AdvertAutoModel.fromJson(Map<String, dynamic> json) {
    return AdvertAutoModel(
      endTime: DateTime.parse(json['endTime']),
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      autoParams: json['autoParams'] != null
          ? AdvertAutoParams.fromJson(json['autoParams'])
          : null,
      name: json['name'],
      dailyBudget: json['dailyBudget'],
      campaignId: json['advertId'],
      status: json['status'],
      type: json['type'],
    );
  }

  @override
  String toString() =>
      'AdvertAutoModel(autoParams: $campaignId, name: $name, endTime: $endTime, createTime: $createTime, changeTime: $changeTime, startTime: $startTime, dailyBudget: $dailyBudget, status: $status, type: $type)';
}

class AdvertAutoParams {
  int? cpm;
  AdvertAutoSubject? subject;
  List<AdvertAutoSet>? sets;
  List<int>? nms;
  AdvertAutoActive? active;
  List<NmCPM>? nmCPM; // Добавлено поле nmCPM

  AdvertAutoParams({
    required this.cpm,
    required this.subject,
    required this.sets,
    required this.nms,
    required this.active,
    required this.nmCPM, // Добавлено поле nmCPM
  });

  factory AdvertAutoParams.fromJson(Map<String, dynamic> json) {
    return AdvertAutoParams(
      cpm: json['cpm'],
      subject: json['subject'] != null
          ? AdvertAutoSubject.fromJson(json['subject'])
          : null,
      sets: json['sets'] != null
          ? List<AdvertAutoSet>.from(
              json['sets'].map((set) => AdvertAutoSet.fromJson(set)))
          : null,
      nms: json['nms'] != null ? List<int>.from(json['nms']) : null,
      active: json['active'] != null
          ? AdvertAutoActive.fromJson(json['active'])
          : null,
      nmCPM: json['nmCPM'] != null
          ? List<NmCPM>.from(json['nmCPM']
              .map((item) => NmCPM.fromJson(item))) // Обработка nmCPM
          : null,
    );
  }
}

class AdvertAutoSubject {
  String? name;
  int? id;

  AdvertAutoSubject({
    required this.name,
    required this.id,
  });

  factory AdvertAutoSubject.fromJson(Map<String, dynamic> json) {
    return AdvertAutoSubject(
      name: json['name'],
      id: json['id'],
    );
  }
}

class AdvertAutoSet {
  String? name;
  int? id;

  AdvertAutoSet({
    required this.name,
    required this.id,
  });

  factory AdvertAutoSet.fromJson(Map<String, dynamic> json) {
    return AdvertAutoSet(
      name: json['name'],
      id: json['id'],
    );
  }
}

class AdvertAutoActive {
  bool? carousel;
  bool? recom;
  bool? booster;

  AdvertAutoActive({
    required this.carousel,
    required this.recom,
    required this.booster,
  });

  factory AdvertAutoActive.fromJson(Map<String, dynamic> json) {
    return AdvertAutoActive(
      carousel: json['carousel'],
      recom: json['recom'],
      booster: json['booster'],
    );
  }
}

class NmCPM {
  int nm;
  int cpm;

  NmCPM({
    required this.nm,
    required this.cpm,
  });

  factory NmCPM.fromJson(Map<String, dynamic> json) {
    return NmCPM(
      nm: json['nm'],
      cpm: json['cpm'],
    );
  }

  @override
  String toString() {
    return 'NmCPM(nm: $nm, cpm: $cpm)';
  }
}
