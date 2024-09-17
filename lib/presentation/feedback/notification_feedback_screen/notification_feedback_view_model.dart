import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/notification.dart';

abstract class NotificationFeedbackTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class NotificationFeedbackNotificationService {
  Future<Either<RewildError, void>> addForParent(
      {required String token,
      required List<ReWildNotificationModel> notifications,
      required int parentId,
      required bool wasEmpty});
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getByCondition(
      List<String> conditions);
}

class NotificationFeedbackState {
  final int newQuestions;
  final int newReviews;

  NotificationFeedbackState({
    required this.newQuestions,
    required this.newReviews,
  });

  factory NotificationFeedbackState.empty() {
    return NotificationFeedbackState(newQuestions: 0, newReviews: 0);
  }

  NotificationFeedbackState copyWith({
    int? questions,
    int? reviews,
  }) {
    return NotificationFeedbackState(
      newReviews: reviews ?? newReviews,
      newQuestions: questions ?? newQuestions,
    );
  }
}

class NotificationFeedbackViewModel extends ResourceChangeNotifier {
  final NotificationFeedbackNotificationService notificationService;
  final NotificationFeedbackTokenService tokenService;
  // final NotificationFeedbackState state;
  NotificationFeedbackViewModel({
    required this.notificationService,
    required this.tokenService,
    required super.context,
  }) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    // SqfliteService.printTableContent('notifications');
    // SqfliteService.printTableContent('unanswered_feedback_qty');
    final savedNotifications = await fetch(() => notificationService
            .getByCondition([
          NotificationConditionConstants.question,
          NotificationConditionConstants.review
        ]));

    if (savedNotifications == null) {
      notify();
      return;
    }
    if (savedNotifications.isNotEmpty) {
      setWasNotEmpty();
    }
    final notifMap = <String, ReWildNotificationModel>{};
    for (var element in savedNotifications) {
      notifMap[element.condition] = element;
    }
    setNotifications(notifMap);
  }

  // Fields
  // there were notifications before
  bool _wasEmpty = true;
  void setWasNotEmpty() {
    _wasEmpty = false;
  }

  Map<String, ReWildNotificationModel> _notifications = {};
  void setNotifications(Map<String, ReWildNotificationModel> notifications) {
    _notifications = notifications;
    notify();
  }

  Map<String, ReWildNotificationModel> get notifications => _notifications;

  Future<void> save() async {
    final tokenOrNull = await fetch(() => tokenService.getToken());

    if (tokenOrNull == null) {
      return;
    }

    final notificationsToSave = _notifications.values.toList();

    await notificationService.addForParent(
        token: tokenOrNull,
        notifications: notificationsToSave,
        parentId: 0,
        wasEmpty: _wasEmpty);

    if (context.mounted) Navigator.of(context).pop();
  }

  bool isInNotifications(String condition) {
    final notification = _notifications[condition];

    if (notification == null) {
      return false;
    }
    return true;
  }

  void dropNotification(String condition) {
    _notifications.remove(condition);
    notifyListeners();
  }

  void addNotification(String condition, int? value, [bool? reusable]) {
    switch (condition) {
      case NotificationConditionConstants.review:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.review,
            value: '',
            reusable: true,
            parentId: 0);

      case NotificationConditionConstants.question:
        _notifications[condition] = ReWildNotificationModel(
            condition: NotificationConditionConstants.question,
            value: '',
            reusable: true,
            parentId: 0);

        break;

      default:
        break;
    }
    notify();
  }
}
