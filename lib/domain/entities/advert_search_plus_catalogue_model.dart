import 'package:rewild_bot_front/domain/entities/advert_base.dart';

class AdvertSearchPlusCatalogueModel extends Advert {
  List<AdvertSearchPlusCatalogueUnitedParam>? unitedParams;

  AdvertSearchPlusCatalogueModel({
    required super.campaignId,
    required super.name,
    required super.endTime,
    required super.createTime,
    required super.changeTime,
    required super.startTime,
    required super.dailyBudget,
    required super.status,
    required super.type,
    this.unitedParams,
  });

  factory AdvertSearchPlusCatalogueModel.fromJson(Map<String, dynamic> json) {
    return AdvertSearchPlusCatalogueModel(
      endTime: DateTime.parse(json['endTime']),
      createTime: DateTime.parse(json['createTime']),
      changeTime: DateTime.parse(json['changeTime']),
      startTime: DateTime.parse(json['startTime']),
      name: json['name'],
      unitedParams: json['unitedParams'] != null
          ? List<AdvertSearchPlusCatalogueUnitedParam>.from(json['unitedParams']
              .map((param) =>
                  AdvertSearchPlusCatalogueUnitedParam.fromJson(param)))
          : null,
      dailyBudget: json['dailyBudget'],
      campaignId: json['advertId'],
      status: json['status'],
      type: json['type'],
    );
  }

  @override
  String toString() =>
      'AdvertSearchPlusCatalogueModel(    campaignId: $campaignId,     name: $name,     endTime: $endTime,     createTime: $createTime,     changeTime: $changeTime,     startTime: $startTime,     dailyBudget: $dailyBudget,     status: $status,     type: $type  )';
}

class AdvertSearchPlusCatalogueUnitedParam {
  int? catalogCPM;
  int? searchCPM;
  AdvertSearchPlusCatalogueSubject? subject;
  List<AdvertSearchPlusCatalogueMenu>? menus;
  List<int>? nms;

  AdvertSearchPlusCatalogueUnitedParam({
    required this.catalogCPM,
    required this.searchCPM,
    required this.subject,
    required this.menus,
    required this.nms,
  });

  factory AdvertSearchPlusCatalogueUnitedParam.fromJson(
      Map<String, dynamic> json) {
    return AdvertSearchPlusCatalogueUnitedParam(
      catalogCPM: json['catalogCPM'],
      searchCPM: json['searchCPM'],
      subject: json['subject'] != null
          ? AdvertSearchPlusCatalogueSubject.fromJson(json['subject'])
          : null,
      menus: json['menus'] != null
          ? List<AdvertSearchPlusCatalogueMenu>.from(json['menus']
              .map((menu) => AdvertSearchPlusCatalogueMenu.fromJson(menu)))
          : null,
      nms: json['nms'] != null ? List<int>.from(json['nms']) : null,
    );
  }
}

class AdvertSearchPlusCatalogueSubject {
  int? id;
  String? name;

  AdvertSearchPlusCatalogueSubject({
    required this.id,
    required this.name,
  });

  factory AdvertSearchPlusCatalogueSubject.fromJson(Map<String, dynamic> json) {
    return AdvertSearchPlusCatalogueSubject(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AdvertSearchPlusCatalogueMenu {
  int? id;
  String? name;

  AdvertSearchPlusCatalogueMenu({
    required this.id,
    required this.name,
  });

  factory AdvertSearchPlusCatalogueMenu.fromJson(Map<String, dynamic> json) {
    return AdvertSearchPlusCatalogueMenu(
      id: json['id'],
      name: json['name'],
    );
  }
}
