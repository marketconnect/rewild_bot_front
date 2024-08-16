import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/metrics_const.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/domain/entities/ab_test.dart';
import 'package:rewild_bot_front/domain/entities/fetch_analitics_detail_result.dart';
import 'package:rewild_bot_front/presentation/ab_test_results_screen/ab_tests_results_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/widgets/metrics_data_table.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';
import 'package:screenshot/screenshot.dart';

class ABTestResultsScreen extends StatefulWidget {
  const ABTestResultsScreen({super.key});

  @override
  State<ABTestResultsScreen> createState() => _ABTestResultsScreenState();
}

class _ABTestResultsScreenState extends State<ABTestResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ABTestsResultsViewModel>();
    final isLoading = model.isLoading;
    final analiticsDetail = model.analiticsDetail;
    final abTest = model.abTest;
    final apiKeyExist = model.apiKeyExists;
    final generateAndSavePdf = model.generateAndSavePdf;
    final aBTestSummaryScreenController = model.aBTestSummaryScreenController;

    final imageUrl = model.image;
    final labesABColorsScreenController = model.labesABColorsScreenController;
    final screenshotFirstController = model.firstRowScreenshotController;
    final screenshotSecondController = model.secondRowScreenshotController;
    final screenshotThirdController = model.thirdRowScreenshotController;
    const myPadding = 8.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Результаты A/B Тестирования',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              if (analiticsDetail != null) {
                generateAndSavePdf(abTest, analiticsDetail);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: MyProgressIndicator())
          : !apiKeyExist
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyWidget(
                        text:
                            'Для работы с аналитикой WB вам необходимо добавить токен "Аналитика".'),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(MainNavigationRouteNames.apiKeysScreen),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: Text(
                              'Добавить токен',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            )))
                  ],
                ))
              : analiticsDetail == null
                  ? const EmptyWidget(
                      text: 'Нет данных',
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Screenshot(
                            controller: aBTestSummaryScreenController,
                            child: ABTestSummary(
                              padding: myPadding,
                              imageUrl: imageUrl ?? "",
                              analyticsDetail: analiticsDetail,
                              testInfo: abTest,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Метрики теста',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(myPadding),
                            child: MetricsDataTable(
                              analyticsDetail: analiticsDetail,
                              firstColHeaderUp: 'Версия B',
                              firstColHeaderDown: '(тестовая)',
                              secondColHeaderUp: 'Версия A',
                              secondColHeaderDown: '(контр.)',
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Анализ воронки продаж',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: myPadding),
                            child: Screenshot(
                              controller: labesABColorsScreenController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      const Text('Версия A (контрольная)'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      const Text('Версия B (тестовая)'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(myPadding),
                            child: Column(
                              children: [
                                Screenshot(
                                  controller: screenshotFirstController,
                                  child: Row(
                                    children: [
                                      ConversionBarChart(
                                          title: 'Переходы в карточку',
                                          previousPeriodValue: analiticsDetail
                                              .statistics
                                              .previousPeriod
                                              .openCardCount
                                              .toDouble(),
                                          selectedPeriodValue: analiticsDetail
                                              .statistics
                                              .selectedPeriod
                                              .openCardCount
                                              .toDouble()),
                                      ConversionBarChart(
                                          title: 'Положили в корзину',
                                          previousPeriodValue: analiticsDetail
                                              .statistics
                                              .previousPeriod
                                              .addToCartCount
                                              .toDouble(),
                                          selectedPeriodValue: analiticsDetail
                                              .statistics
                                              .selectedPeriod
                                              .addToCartCount
                                              .toDouble()),
                                    ],
                                  ),
                                ),
                                Screenshot(
                                  controller: screenshotSecondController,
                                  child: Row(
                                    children: [
                                      ConversionBarChart(
                                          title: 'Заказали товаров',
                                          previousPeriodValue: analiticsDetail
                                              .statistics
                                              .previousPeriod
                                              .ordersCount
                                              .toDouble(),
                                          selectedPeriodValue: analiticsDetail
                                              .statistics
                                              .selectedPeriod
                                              .ordersCount
                                              .toDouble()),
                                      ConversionBarChart(
                                          title: 'Заказали на сумму',
                                          previousPeriodValue: analiticsDetail
                                              .statistics
                                              .previousPeriod
                                              .ordersSumRub
                                              .toDouble(),
                                          selectedPeriodValue: analiticsDetail
                                              .statistics
                                              .selectedPeriod
                                              .ordersSumRub
                                              .toDouble()),
                                    ],
                                  ),
                                ),
                                Screenshot(
                                  controller: screenshotThirdController,
                                  child: Row(
                                    children: [
                                      ConversionBarChart(
                                          title: 'Выкупили товаров',
                                          previousPeriodValue: analiticsDetail
                                              .statistics
                                              .previousPeriod
                                              .buyoutsCount
                                              .toDouble(),
                                          selectedPeriodValue: analiticsDetail
                                              .statistics
                                              .selectedPeriod
                                              .buyoutsCount
                                              .toDouble()),
                                      ConversionBarChart(
                                          title: 'Выкупили на сумму',
                                          previousPeriodValue: analiticsDetail
                                              .statistics
                                              .previousPeriod
                                              .buyoutsSumRub
                                              .toDouble(),
                                          selectedPeriodValue: analiticsDetail
                                              .statistics
                                              .selectedPeriod
                                              .buyoutsSumRub
                                              .toDouble()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class ConversionBarChart extends StatelessWidget {
  final String title;
  final double selectedPeriodValue;
  final double previousPeriodValue;

  const ConversionBarChart({
    super.key,
    required this.selectedPeriodValue,
    required this.previousPeriodValue,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: const EdgeInsets.only(8),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: max(selectedPeriodValue, previousPeriodValue) * 1.2,
                titlesData: const FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: selectedPeriodValue,
                        color: Colors.blue,
                        width: MediaQuery.of(context).size.width * 0.15,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: previousPeriodValue,
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width * 0.15,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ],
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    // tooltipBgColor: Colors.transparent,
                    tooltipPadding: const EdgeInsets.all(0),
                    tooltipMargin: 8,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(2),
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ABTestSummary extends StatelessWidget {
  final ABTest testInfo;
  final AnaliticsDetail analyticsDetail;
  final double padding;
  final String imageUrl;
  const ABTestSummary({
    super.key,
    required this.testInfo,
    required this.padding,
    required this.imageUrl,
    required this.analyticsDetail,
  });

  @override
  Widget build(BuildContext context) {
    final selected = analyticsDetail.statistics.selectedPeriod;

    final previous = analyticsDetail.statistics.previousPeriod;
    bool isTestSuccessful = false;

    switch (testInfo.metrics) {}

    switch (testInfo.metrics) {
      case EnumMetrics.addToCartPercent:
        isTestSuccessful = selected.conversions.addToCartPercent >
            previous.conversions.addToCartPercent;

        break;
      case EnumMetrics.cartToOrderPercent:
        isTestSuccessful = selected.conversions.cartToOrderPercent >
            previous.conversions.cartToOrderPercent;
        break;

      case EnumMetrics.avgPriceRub:
        isTestSuccessful = selected.avgPriceRub > previous.avgPriceRub;
        break;
      case EnumMetrics.cancelCount:
        isTestSuccessful = selected.cancelCount > previous.cancelCount;
        break;
      case EnumMetrics.openCardCount:
        isTestSuccessful = selected.openCardCount > previous.openCardCount;
        break;
      case EnumMetrics.ordersCount:
        isTestSuccessful = selected.ordersCount > previous.ordersCount;
        break;
      default:
        break;
    }
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Основная информация',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Название теста:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(testInfo.changesDescription)),
                  const SizedBox(height: 8),
                  const Text(
                    'Артикул:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(analyticsDetail.vendorCode),
                  const SizedBox(height: 8),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReWildNetworkImage(
                  image: imageUrl,
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Период тестирования:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
              'Версия A (контрольная): ${formatDate(previous.begin)} по ${formatDate(previous.end)}'),
          Text(
              'Версия B (тестовая): ${formatDate(selected.begin)} по ${formatDate(selected.end)}'),
          // Text('
          //  с ${formatDate(testInfo.startDate)} по ${formatDate(testInfo.endDate)}'),

          const SizedBox(height: 8),

          const Text('Метрика теста:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(testInfo.metrics),
          // Text('Статус теста: ${testInfo.status}'),
          const SizedBox(height: 8),
          Text(
            'Вывод: Тест ${isTestSuccessful ? "успешен" : "не успешен"}',
            style: TextStyle(
              color: isTestSuccessful ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Можно добавить дополнительные детали и выводы об A/B тесте
        ],
      ),
    );
  }
}
