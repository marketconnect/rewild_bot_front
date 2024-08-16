import 'package:flutter/material.dart';
import 'package:rewild_bot_front/domain/entities/fetch_analitics_detail_result.dart';

class MetricsDataTable extends StatefulWidget {
  const MetricsDataTable(
      {super.key,
      required this.analyticsDetail,
      required this.firstColHeaderDown,
      required this.secondColHeaderDown,
      required this.secondColHeaderUp,
      required this.firstColHeaderUp});
  final AnaliticsDetail analyticsDetail;
  final String firstColHeaderUp,
      firstColHeaderDown,
      secondColHeaderUp,
      secondColHeaderDown;

  @override
  State<MetricsDataTable> createState() => _MetricsDataTableState();
}

class _MetricsDataTableState extends State<MetricsDataTable> {
  @override
  Widget build(BuildContext context) {
    final selectedPeriod = widget.analyticsDetail.statistics.selectedPeriod;
    final previousPeriod = widget.analyticsDetail.statistics.previousPeriod;
    final comparison = widget.analyticsDetail.statistics.periodComparison;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 0,
        horizontalMargin: 0,
        dividerThickness: 0,
        headingRowHeight: MediaQuery.of(context).size.width * 0.1,
        columns: [
          DataColumn(
              label: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: const Text(
                    '',
                  ))),
          DataColumn(
              label: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.firstColHeaderUp,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03)),
                      Text(widget.firstColHeaderDown,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03)),
                    ],
                  ))),
          DataColumn(
              label: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.secondColHeaderUp,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03)),
                      Text(widget.secondColHeaderDown,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03)),
                    ],
                  ))),
          DataColumn(
              label: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Динамика",
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03)),
                    ],
                  ))),
        ],
        rows: [
          _createDataRow(
              'Переходов в карточку',
              selectedPeriod.openCardCount.toString(),
              previousPeriod.openCardCount.toString(),
              '${comparison.openCardDynamics}%'),
          _createDataRow(
              'Добавлений в корзину',
              selectedPeriod.addToCartCount.toString(),
              previousPeriod.addToCartCount.toString(),
              '${comparison.addToCartDynamics}%',
              true),
          _createDataRow(
              'Заказов',
              selectedPeriod.ordersCount.toString(),
              previousPeriod.ordersCount.toString(),
              '${comparison.ordersCountDynamics}%'),
          _createDataRow(
              'Заказов на сумму',
              '${selectedPeriod.ordersSumRub} ₽',
              '${previousPeriod.ordersSumRub} ₽',
              '${comparison.ordersSumRubDynamics}%',
              true),
          _createDataRow(
              'Выкупили',
              selectedPeriod.buyoutsCount.toString(),
              previousPeriod.buyoutsCount.toString(),
              '${comparison.buyoutsCountDynamics}%'),
          _createDataRow(
              'Выкупили на сумму',
              '${selectedPeriod.buyoutsSumRub} ₽',
              '${previousPeriod.buyoutsSumRub} ₽',
              '${comparison.buyoutsSumRubDynamics}%',
              true),
          _createDataRow(
              'Отменили товаров',
              selectedPeriod.cancelCount.toString(),
              previousPeriod.cancelCount.toString(),
              '${comparison.cancelCountDynamics}%'),
          _createDataRow(
              'Отменили на сумму',
              '${selectedPeriod.cancelSumRub} ₽',
              '${previousPeriod.cancelSumRub} ₽',
              '${comparison.cancelSumRubDynamics}%',
              true),
          _createDataRow(
            'Средняя цена',
            '${selectedPeriod.avgPriceRub} ₽',
            '${previousPeriod.avgPriceRub} ₽',
            '${comparison.avgPriceRubDynamics}%',
          ),
          _createDataRow(
              'Ср. кол-во заказов в день',
              selectedPeriod.avgOrdersCountPerDay.toString(),
              previousPeriod.avgOrdersCountPerDay.toString(),
              '${comparison.avgOrdersCountPerDayDynamics}%',
              true),
          _createDataRow(
            'Конверсия в корзину',
            '${selectedPeriod.conversions.addToCartPercent}%',
            '${previousPeriod.conversions.addToCartPercent}%',
            '${comparison.conversions.addToCartPercent}%',
          ),
          _createDataRow(
              'Конверсия в заказ,',
              '${selectedPeriod.conversions.cartToOrderPercent}%',
              '${previousPeriod.conversions.cartToOrderPercent}%',
              '${comparison.conversions.cartToOrderPercent}%',
              true),
          _createDataRow(
            'Процент выкупа',
            '${selectedPeriod.conversions.buyoutsPercent}%',
            '${previousPeriod.conversions.buyoutsPercent}%',
            '${comparison.conversions.buyoutsPercent}%',
          ),
        ],
      ),
    );
  }

  DataRow _createDataRow(String metric, String selectedValue,
      String previousValue, String comparison,
      [bool isEven = false]) {
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (isEven) {
          return Theme.of(context).colorScheme.surface;
        } else {
          return const Color(0xFFF8F9FA); // Светло-серый цвет
        }
      }),
      cells: [
        DataCell(SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                metric,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03),
              ),
            ))),
        DataCell(SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              selectedValue,
              textAlign: TextAlign.center,
              maxLines: 1,
            ))),
        DataCell(SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              previousValue,
              textAlign: TextAlign.center,
              maxLines: 1,
            ))),
        DataCell(SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              comparison,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  color: comparison == "0%"
                      ? null
                      : comparison.startsWith("-") &&
                              metric != 'Отменили товаров' &&
                              metric != 'Отменили на сумму'
                          ? Colors.red
                          : const Color(0xFF007c32)),
            ))),
      ],
    );
  }
}
