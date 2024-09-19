import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/notification.dart';
import 'package:rewild_bot_front/domain/entities/warehouse.dart';

abstract class NotificationCardTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class NotificationCardNotificationService {
  Future<Either<RewildError, void>> addForParent(
      {required String token,
      required List<ReWildNotificationModel> notifications,
      required int parentId,
      required bool wasEmpty});
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      {required int parentId});
}

class NotificationCardState {
  final int nmId;
  final int price;
  final String name;
  final String promo;
  final int pics;
  final double reviewRating;
  final Map<Warehouse, int> warehouses;
  NotificationCardState(
      {required this.nmId,
      required this.pics,
      required this.reviewRating,
      required this.price,
      required this.name,
      required this.promo,
      required this.warehouses});

  factory NotificationCardState.empty() {
    return NotificationCardState(
        nmId: 0,
        pics: 0,
        name: '',
        reviewRating: 0,
        price: 0,
        promo: "",
        warehouses: {});
  }

  NotificationCardState copyWith({
    int? nmId,
    int? price,
    String? promo,
    int? pics,
    String? name,
    double? reviewRating,
    Map<Warehouse, int>? warehouses,
  }) {
    return NotificationCardState(
      nmId: nmId ?? this.nmId,
      price: price ?? this.price,
      promo: promo ?? this.promo,
      name: name ?? this.name,
      pics: pics ?? this.pics,
      reviewRating: reviewRating ?? this.reviewRating,
      warehouses: warehouses ?? this.warehouses,
    );
  }
}

class CardNotificationViewModel extends ResourceChangeNotifier {
  CardNotificationViewModel(
    this.state, {
    required this.notificationService,
    required this.tokenService,
    required super.context,
  }) {
    _asyncInit();
  }

  // constructor params
  final NotificationCardNotificationService notificationService;
  final NotificationCardState state;
  final NotificationCardTokenService tokenService;

  // // Fields
  bool _isLoading = false;

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notify();
  }

  bool get isLoading => _isLoading;

  bool _wasEmpty = true;
  void setWasNotEmpty() {
    _wasEmpty = false;
  }

  int? _stocks;

  int get stocks => _stocks ?? 0;

  // notifications
  final Map<String, ReWildNotificationModel> _notifications = {};
  void setNotifications(Map<String, ReWildNotificationModel> notifications) {
    _notifications.clear();
    _notifications.addAll(notifications);

    notify();
  }

  Map<String, ReWildNotificationModel> get notifications => _notifications;

  Map<Warehouse, int> get warehouses => state.warehouses;

  // Methods ===================================================================

  Future<void> _asyncInit() async {
    setIsLoading(true);
    final savedNotifications = await fetch(
        () => notificationService.getForParent(parentId: state.nmId));
    if (savedNotifications == null) {
      setIsLoading(false);
      return;
    }

    if (savedNotifications.isNotEmpty) {
      setWasNotEmpty();
      setIsLoading(false);
    }

    Map<String, ReWildNotificationModel> notifications = {};

    for (var element in savedNotifications) {
      notifications[element.condition] = element;
    }

    _stocks = state.warehouses.entries
        .fold(0, (previousValue, element) => previousValue! + element.value);

    setNotifications(notifications);

    setIsLoading(false);
  }

  Future<void> save() async {
    final tokenOrNull = await fetch(() => tokenService.getToken());
    if (tokenOrNull == null) {
      return;
    }
    final listToAdd = _notifications.values.toList();

    await notificationService.addForParent(
        token: tokenOrNull,
        notifications: listToAdd,
        parentId: state.nmId,
        wasEmpty: _wasEmpty);

    if (context.mounted) Navigator.of(context).pop();
  }

  bool isInNotifications(String condition, {int? wh}) {
    String notificationKey = wh != null ? '$condition-$wh' : condition;
    final notification = _notifications[notificationKey];

    if (notification == null) {
      return false;
    }

    // if (wh != null && notification.wh != wh) {
    //   return false;
    // }

    return true;
  }

  void dropNotification(String condition, {int? wh}) {
    String notificationKey = wh != null ? '$condition-$wh' : condition;
    _notifications.remove(notificationKey);
    notify();
  }

  void addNotification(
    String condition,
    num? value, {
    int? wh,
    String? whName,
  }) {
    print(
        "pressed add notification for $condition with value $value and wh $wh and whName $whName");
    String notificationKey = wh != null ? '$condition-$wh' : condition;
    switch (condition) {
      case NotificationConditionConstants.nameChanged:
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: NotificationConditionConstants.nameChanged,
            value: state.name,
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.picsChanged:
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: NotificationConditionConstants.picsChanged,
            value: state.pics.toString(),
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.priceChanged:
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: NotificationConditionConstants.priceChanged,
            value: state.price.toString(),
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.promoChanged:
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: NotificationConditionConstants.promoChanged,
            value: state.promo,
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.reviewRatingChanged:
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: NotificationConditionConstants.reviewRatingChanged,
            value: state.reviewRating.toString(),
            reusable: true,
            parentId: state.nmId);

        break;
      case NotificationConditionConstants.totalStocksLessThan:
        print('totalStocksLessThan $condition $value $wh $whName');
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: NotificationConditionConstants.totalStocksLessThan,
            reusable: true,
            value: value.toString(),
            parentId: state.nmId);

        break;

      case NotificationConditionConstants.stocksLessThan:
        print('stocksLessThan $condition $value $wh $whName');
        _notifications[notificationKey] = ReWildNotificationModel(
            condition: condition,
            reusable: true,
            value: value.toString(),
            parentId: state.nmId,
            wh: wh,
            whName: whName);

        break;
      default:
        break;
    }
    // since there can be many warehouses, and to add all of them we need to make condition different (100 + wh)
    // if (condition > 100) {
    //   _notifications[condition] = ReWildNotificationModel(
    //       condition: condition,
    //       reusable: true,
    //       value: value.toString(),
    //       parentId: state.nmId,
    //       wh: wh);
    // }
    notify();
  }
}
