import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/widgets/mutable_notification_card.dart';
import 'package:rewild_bot_front/widgets/unmutable_notification_card.dart';

class NotificationCardSettingsScreen extends StatelessWidget {
  const NotificationCardSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CardNotificationViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final save = model.save;
    final state = model.state;
    final add = model.addNotification;
    final drop = model.dropNotification;
    final isActive = model.isInNotifications;
    final stocks = model.stocks;
    final warehouses = model.warehouses;
    final notifStocks =
        model.notifications[NotificationConditionConstants.stocksLessThan];
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.2),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.nameChanged,
            currentValue: "",
            topBorder: true,
            text: 'Изменение в названии',
            isActive: isActive(NotificationConditionConstants.nameChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.promoChanged,
            currentValue: "",
            text: 'Изменение акции',
            isActive: isActive(NotificationConditionConstants.promoChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.priceChanged,
            currentValue: (state.price ~/ 100).toString(),
            suffix: '₽',
            text: 'Изменение цены',
            isActive: isActive(NotificationConditionConstants.priceChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.reviewRatingChanged,
            currentValue: state.reviewRating.toString(),
            text: 'Изменение рейтинга',
            isActive:
                isActive(NotificationConditionConstants.reviewRatingChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          UnmutableNotificationCard(
            condition: NotificationConditionConstants.picsChanged,
            currentValue: state.pics.toString(),
            suffix: 'шт.',
            text: 'Изменение картинок',
            isActive: isActive(NotificationConditionConstants.picsChanged),
            addNotification: add,
            dropNotification: drop,
          ),
          if (!model.isLoading)
            MutableNotificationCard(
              condition: NotificationConditionConstants.stocksLessThan,
              currentValue: notifStocks == null
                  ? stocks
                  : int.tryParse(notifStocks.value),
              text: 'Остатки ${stocks > 50000 ? '<' : ' менее'}',
              suffix: 'шт.',
              isActive:
                  isActive(NotificationConditionConstants.totalStocksLessThan),
              addNotification: add,
              dropNotification: drop,
            ),
          if (!model.isLoading)
            for (var warehouse in warehouses.entries)
              MutableNotificationCard(
                // since there can be many warehouses,
                //and to add all of them we need to make condition different (100 + wh)
                condition: NotificationConditionConstants.stocksLessThan +
                    warehouse.key.id.toString(),
                currentValue: warehouse.value,
                text: '${warehouse.key.name} менее',
                suffix: 'шт.',
                isActive: isActive(
                    NotificationConditionConstants.stocksLessThan +
                        warehouse.key.id.toString(),
                    wh: warehouse.key.id),
                addNotification: (condition, value) => add(condition, value,
                    wh: warehouse.key.id, whName: warehouse.key.name),
                dropNotification: (condition) =>
                    drop(condition, wh: warehouse.key.id),
              ),
        ]),
      ),
    );
  }
}
