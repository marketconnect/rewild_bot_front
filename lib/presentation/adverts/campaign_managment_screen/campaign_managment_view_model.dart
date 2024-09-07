import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/core/utils/text_filed_validator.dart';
import 'package:rewild_bot_front/domain/entities/advert_auto_model.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild_bot_front/domain/entities/notification.dart';
import 'package:rewild_bot_front/widgets/my_dialog_textfield_radio.dart';
import 'package:rewild_bot_front/widgets/my_dialog_textfield_radio_checkbox.dart';

abstract class CampaignManagementNotificationService {
  Future<Either<RewildError, void>> addForParent(
      {required List<ReWildNotificationModel> notifications,
      required int parentId,
      required bool wasEmpty});
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      {required int parentId});
}

abstract class CampaignManagementAdvertService {
  Future<Either<RewildError, int>> depositCampaignBudget({
    required int campaignId,
    required int sum,
  });
  Future<Either<RewildError, List<Advert>>> getAll(
      {required String token, List<int>? types});
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> checkAdvertIsActive(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> stopAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId});

  Future<Either<RewildError, bool>> setCpm(
      {required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

enum CampaignStatus { active, paused }

class CampaignManagementViewModel extends ResourceChangeNotifier {
  final int campaignId;
  final CampaignManagementAdvertService advertService;
  final CampaignManagementNotificationService notificationService;
  CampaignManagementViewModel({
    required this.campaignId,
    required this.advertService,
    required this.notificationService,
    required super.context,
  }) {
    _asyncInit();
  }

  void _asyncInit() async {
    // Api key
    final apiKey = await fetch(() => advertService.getApiKey());

    if (apiKey == null) {
      return;
    }

    setApiKey(apiKey);

    // Get advert info
    final adverts = await fetch(() => advertService.getAll(token: apiKey));
    if (adverts == null) {
      return;
    }

    final advertsList = adverts.where(
      (element) => element.campaignId == campaignId,
    );
    if (advertsList.isEmpty) {
      return;
    }

    final advert = advertsList.first;

    // set status
    setActive(advert.status == AdvertStatusConstants.active);

    // set title and cpm
    _setTitleCpm(advert);

    // set budget
    final budget = await fetch(
        () => advertService.getBudget(token: _apiKey!, campaignId: campaignId));
    if (budget != null) {
      _budget = budget;
      notify();
    }

    // set notifications
    final savedNotifications = await fetch(
        () => notificationService.getForParent(parentId: campaignId));
    if (savedNotifications == null) {
      return;
    }

    if (savedNotifications.isNotEmpty) {
      setWasNotEmpty();
      final notMinBudg = int.tryParse(savedNotifications.first.value);

      _minBudgetLimit = notMinBudg ?? _minBudgetLimit;
      if (_minBudgetLimit != null && _minBudgetLimit! >= 0) {
        setNotifyAboutMinimumBudget(true);
      }
      notify();
    }
  }

  // loading
  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  // Change cpm Dialog widget
  Widget? changeCpmDialog;

  void setChangeCpmDialog(Widget widget) {
    changeCpmDialog = widget;
  }

  // if  status or budget was changed send message to the main screen
  // that it update itself
  bool _wasStatusOrBudgetChanged = false;
  set wasStatusOrBudgetChangedDoNotUSed(bool value) {
    _wasStatusOrBudgetChanged = value;
  }

  bool get wasStatusOrBudgetChanged => _wasStatusOrBudgetChanged;

  String? _title;
  void setTitle(String value) {
    _title = value;
    notify();
  }

  String get title => _title ?? '';

  // adv type
  int? _advType;
  void setAdvType(int value) {
    _advType = value;
    notify();
  }

  // api key
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  bool get apiKeyExists => _apiKey != null;

  // status
  bool? _isActive;
  void setActive(bool value) {
    _isActive = value;
  }

  bool? get isActive => _isActive;

  // Budget
  int? _budget;
  void setBudget(String value) async {
    _budget = int.tryParse(value);
    if (_budget != null && _budget! < 0) {
      _budget = 0;
      return;
    }
    final resBudgOrNull = await fetch(() => advertService.depositCampaignBudget(
        campaignId: campaignId, sum: _budget!));
    if (resBudgOrNull == null) {
      notify();
      return;
    }
    _budget = resBudgOrNull;
    _wasStatusOrBudgetChanged = true;
    notify();
  }

  int? get budget => _budget;

  // budget notification
  bool _wasEmpty = true;
  void setWasNotEmpty() {
    _wasEmpty = false;
  }

  bool _notifyAboutMinimumBudget = false;
  void setNotifyAboutMinimumBudget(bool value) {
    if (!value) {
      _minBudgetLimit = null;
    }
    _notifyAboutMinimumBudget = value;
    notify();
  }

  bool get notifyAboutMinimumBudget => _notifyAboutMinimumBudget;

  int? _minBudgetLimit;
  void setMinBudgetLimit(int? value) {
    _minBudgetLimit = value;
    notify();
  }

  int? get minBudgetLimit => _minBudgetLimit;

  Future<void> saveNotification() async {
    final notificationsToSave = ReWildNotificationModel(
        parentId: campaignId,
        condition: NotificationConditionConstants.budgetLessThan,
        value: _minBudgetLimit.toString());

    await notificationService.addForParent(
        notifications: _minBudgetLimit == null ? [] : [notificationsToSave],
        parentId: campaignId,
        wasEmpty: _wasEmpty);
  }

  // Cpm
  int? _searchCpm;
  int? _catalogCpm;
  void setCpm(int searhcCpm, [int? catalogCpm]) {
    _searchCpm = searhcCpm;
    _catalogCpm = catalogCpm;
    notify();
  }

  int? get saerchCpm => _searchCpm;
  int? get cpmCatalog => _catalogCpm;

  Future<void> _changeCpm({required String value, required int option}) async {
    final cpm = int.tryParse(value) ?? 0;

    // if (_searchCpm == null || _advType == null) {
    //   return;
    // }
    if (_apiKey == null) {
      return;
    }

    await fetch(() => advertService.setCpm(
        campaignId: campaignId, cpm: cpm, type: _advType!, param: option));
    // _wasCpmOrBudgetChanged = true;
    _asyncInit();
  }

  Future<void> _changeCpmInSearchAndCatalog(
      {required String value,
      required int option,
      required int option1}) async {
    final cpm = int.tryParse(value) ?? 0;
    if (_searchCpm == null || _advType == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
        campaignId: campaignId,
        cpm: cpm,
        type: _advType!,
        param: option1,
        instrument: option));
    _wasStatusOrBudgetChanged = true;
    _asyncInit();
  }

  Future<void> changeAdvertStatus() async {
    if (_budget == null || _budget == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бюджет равен нулю'),
        ),
      );
      return;
    }
    if (_apiKey == null || _isActive == null) {
      return;
    }

    if (_budget == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бюджет равен нулю'),
        ),
      );
    }

    setIsLoading(true);

    if (_isActive!) {
      // now the advert is not paused
      // stop
      final _ = await fetch(() =>
          advertService.stopAdvert(token: _apiKey!, campaignId: campaignId));
      _wasStatusOrBudgetChanged = true;
      setActive(false);
      setIsLoading(false);
      return;
    } else {
      // now the advert is paused
      // start
      final _ = await fetch(() =>
          advertService.startAdvert(token: _apiKey!, campaignId: campaignId));
      _wasStatusOrBudgetChanged = true;
      setActive(true);
      setIsLoading(false);
      return;
    }
  }

  void _setTitleCpm(Advert advertInfo) {
    _advType = advertInfo.type;
    Map<int, String> textInputOptions = {};
    Map<int, String> radioOptions = {};
    setTitle(advertInfo.name);
    switch (advertInfo.type) {
      case AdvertTypeConstants.auto:
        if (advertInfo is AdvertAutoModel &&
            advertInfo.autoParams != null &&
            advertInfo.autoParams!.cpm != null) {
          setCpm(advertInfo.autoParams!.cpm!);
          final cpm = advertInfo.autoParams!.cpm;
          if (advertInfo.autoParams!.subject != null) {
            final subjectId = advertInfo.autoParams!.subject!.id!;
            final subjectName = advertInfo.autoParams!.subject!.name!;
            textInputOptions[subjectId] = "$cpm₽";
            radioOptions[subjectId] = subjectName;
          }
        } else if (advertInfo is AdvertAutoModel &&
            advertInfo.autoParams!.subject != null) {
          final subjectId = advertInfo.autoParams!.subject!.id!;
          final subjectName = advertInfo.autoParams!.subject!.name!;
          textInputOptions[subjectId] = "0₽";
          radioOptions[subjectId] = subjectName;
        }
        break;
      // case AdvertTypeConstants.inSearch:
      //   if (advertInfo is AdvertSearchModel &&
      //       advertInfo.params != null &&
      //       advertInfo.params!.first.price != null) {
      //     setCpm(advertInfo.params!.first.price!);
      //     if (advertInfo.params != null) {
      //       final params = advertInfo.params;
      //       for (final param in params!) {
      //         if (param.subjectId != null) {
      //           final subjectId = param.subjectId!;
      //           final subjectName = param.subjectName ?? "";
      //           final cpm = param.price;
      //           textInputOptions[subjectId] = "$cpm₽";
      //           radioOptions[subjectId] = subjectName;
      //         }
      //       }
      //     }
      //   }
      //   break;
      // case AdvertTypeConstants.inCard:
      //   if (advertInfo is AdvertCardModel &&
      //       advertInfo.params != null &&
      //       advertInfo.params!.first.price != null &&
      //       advertInfo.params!.first.setId != null) {
      //     setCpm(advertInfo.params!.first.price!);
      //     final params = advertInfo.params;
      //     for (final param in params!) {
      //       if (param.setId != null) {
      //         final setId = param.setId!;
      //         final setName = param.setName ?? "";
      //         final cpm = param.price;
      //         textInputOptions[setId] = "$cpm₽";
      //         radioOptions[setId] = setName;
      //       }
      //     }
      //   }
      //   break;
      // case AdvertTypeConstants.inCatalog:
      //   if (advertInfo is AdvertCatalogueModel &&
      //       advertInfo.params != null &&
      //       advertInfo.params!.first.price != null) {
      //     for (var param in advertInfo.params!) {
      //       radioOptions[param.menuId!] = param.menuName!;
      //       textInputOptions[param.menuId!] = '${param.price!}₽';
      //     }

      //     setCpm(advertInfo.params!.first.price!);
      //     if (advertInfo.params!.first.menuId != null) {
      //       setChangeCpmDialog(MyDialogTextFieldRadio(
      //         header: "Ставка (СРМ, ₽)",
      //         addGroup: _changeCpm,
      //         radioOptions: radioOptions,
      //         textInputOptions: textInputOptions,
      //         validator: TextFieldValidator.isNumericAndGreaterThanN,
      //         btnText: "Обновить",
      //         description: "Введите новое значение ставки",
      //         keyboardType: TextInputType.number,
      //       ));
      //     }
      //   }

      //   break;

      // case AdvertTypeConstants.inRecomendation:
      //   if (advertInfo is AdvertRecomendaionModel &&
      //       advertInfo.params != null &&
      //       advertInfo.params!.first.price != null) {
      //     for (var param in advertInfo.params!) {
      //       radioOptions[param.subjectId!] = param.subjectName!;
      //       textInputOptions[param.subjectId!] = '${param.price!}₽';
      //     }
      //     setCpm(advertInfo.params!.first.price!);
      //   }

      //   break;
      case AdvertTypeConstants.searchPlusCatalog:
        if (advertInfo is AdvertSearchPlusCatalogueModel &&
            advertInfo.unitedParams != null &&
            advertInfo.unitedParams!.first.catalogCPM != null) {
          setCpm(advertInfo.unitedParams!.first.searchCPM!,
              advertInfo.unitedParams!.first.catalogCPM!);
          final params = advertInfo.unitedParams!;
          final Map<int, String> checkBoxOptions = {};
          for (final param in params) {
            checkBoxOptions[param.subject!.id!] = param.subject!.name!;
          }
          textInputOptions[4] = "${params.first.catalogCPM!}₽";
          textInputOptions[6] = "${params.first.searchCPM!}₽";
          radioOptions[4] = "Каталог";
          radioOptions[6] = "Поиск";

          setChangeCpmDialog(MyDialogTextFieldRadioCheckBox(
            header: "Ставка (СРМ, ₽)",
            checkBoxOptions: checkBoxOptions,
            radioOptions: radioOptions,
            textInputOptions: textInputOptions,
            addGroup: _changeCpmInSearchAndCatalog,
            validator: TextFieldValidator.isNumericAndGreaterThanN,
            btnText: "Обновить",
            description: "Введите новое значение ставки",
            keyboardType: TextInputType.number,
          ));
        }

        break;
    }
    if (textInputOptions.keys.isNotEmpty &&
        _advType != AdvertTypeConstants.searchPlusCatalog) {
      setChangeCpmDialog(MyDialogTextFieldRadio(
        header: "Ставка (СРМ, ₽)",
        textInputOptions: textInputOptions,
        radioOptions: radioOptions,
        addGroup: _changeCpm,
        validator: TextFieldValidator.isNumericAndGreaterThanN,
        btnText: "Обновить",
        description: "Введите новое значение ставки",
        keyboardType: TextInputType.number,
      ));
    }
  }
}
