import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/presentation/feedback/notification_feedback_screen/notification_feedback_view_model.dart';
import 'package:rewild_bot_front/widgets/unmutable_notification_card.dart';

class NotificationFeedbackSettingsScreen extends StatelessWidget {
  const NotificationFeedbackSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotificationFeedbackViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final save = model.save;
    final add = model.addNotification;
    final drop = model.dropNotification;
    final isActive = model.isInNotifications;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Уведомления',
          style: TextStyle(
              fontSize: screenWidth * 0.06,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.2),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(3),
        width: model.screenWidth,
        child: FloatingActionButton(
          onPressed: () async {
            await save();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text("Сохранить",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.question,
            currentValue: "",
            text: 'Новые вопросы',
            isActive: isActive(NotificationConditionConstants.question),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.review,
            currentValue: "",
            text: 'Новые отзывы',
            isActive: isActive(NotificationConditionConstants.review),
            addNotification: add,
            dropNotification: drop,
          ),
        ]),
      ),
    );
  }
}
