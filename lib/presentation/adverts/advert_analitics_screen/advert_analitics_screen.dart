// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';

// import 'package:rewild/widgets/progress_indicator.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/campaign_data.dart';
import 'package:rewild_bot_front/presentation/adverts/advert_analitics_screen/advert_analitics_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/date_range_picker_widget.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class AdvertAnaliticsScreen extends StatelessWidget {
  const AdvertAnaliticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();

    final name = model.campaignName;
    final isLoading = model.isLoading;
    // final loadingText = model.loadingText;
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),
        body:
            // isLoading
            //     ? Center(
            //         child: MyProgressIndicator(
            //         text: loadingText,
            //       ))
            //     :
            _bodyBuilder(context),
      ),
    );
  }

  Widget _bodyBuilder(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();
    final apiKeyExist = model.apiKeyExists;

    // before api key was added
    if (!apiKeyExist) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyWidget(
              text:
                  'Для работы с отзывами и вопросами WB вам необходимо добавить токен "Продвижение".'),
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
                        color: Theme.of(context).colorScheme.onPrimary),
                  )))
        ],
      ));
    }

    return const _Body();
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();

    final images = model.images;

    final noDays = model.noDays;
    final noPreviousDays = model.noPreviousDays;
    final startDate = model.startDate;
    final endDate = model.endDate;
    final setStartDate = model.setStartDate;
    final setEndDate = model.setEndDate;
    final fetchCampaignData = model.fetchCampaignData;
    List<CampaignDataDay> selectedDays = model.selectedData;
    final createdAt = model.createdAt;
    final currentDetailNmId = model.currentDetailNmId;
    final gotNullFromWb = model.gotNullFromWb;
    if (currentDetailNmId != -1) {
      final getNmIdsSelectedData =
          model.getNmIdsSelectedData(currentDetailNmId);

      if (getNmIdsSelectedData != null) {
        selectedDays = getNmIdsSelectedData;
      }
    }

    if (noDays) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (gotNullFromWb)
            const Center(
                child: EmptyWidget(
                    text:
                        'API Wildberries вернул ошибку, так как в интервале присутсвуют дни, в которых кампания не была запущена.')),
          DateRangePickerWidget(
            // centerBtn: true,
            btnText: 'Выберите период для аналитики',
            lastAllowable: DateTime.now(),
            firstAllowable: createdAt,
            initDateTimeRange: DateTimeRange(
              start: startDate,
              end: endDate,
            ),
            onDateRangeSelected: (start, end) {
              setStartDate(start);
              setEndDate(end);
              fetchCampaignData();
            },
          ),
        ],
      );
    }

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.length > 1) const HorizontalProductImages(),
        // DateRangePickerWidget(
        //   // centerBtn: true,
        //   btnText: 'Выберите период для аналитики',
        //   lastAllowable: DateTime.now().subtract(const Duration(days: 1)),
        //   firstAllowable: DateTime(2010, 1, 1),
        //   initDateTimeRange: DateTimeRange(
        //     start: startDate,
        //     end: endDate,
        //   ),
        //   onDateRangeSelected: (start, end) {
        //     setStartDate(start);
        //     setEndDate(end);
        //     fetchCampaignData();
        //   },
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(),
              noPreviousDays
                  ? const SoleCampaignData()
                  : const MultiCampaignData(),
              const Divider(),
              const SizedBox(
                height: 30,
              ),
              CampaignMetricsChart(
                dataDays: selectedDays,
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(),
              const _Efficiency(),
            ],
          ),
        ),
      ],
    ));
  }
}

class HorizontalProductImages extends StatelessWidget {
  const HorizontalProductImages({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();
    final currentDetailNmId = model.currentDetailNmId;
    final setCurrentDetailNmId = model.setCurrentDetailNmId;
    final images = model.images;
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          GestureDetector(
            onTap: () => setCurrentDetailNmId(-1),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width * 0.207,
              height: MediaQuery.of(context).size.width * 0.207,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border.all(
                    width: currentDetailNmId == -1 ? 3 : 1,
                    color: currentDetailNmId == -1
                        ? Theme.of(context).primaryColor.withOpacity(0.7)
                        : Theme.of(context).colorScheme.primaryContainer),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'По всем',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          ...images.entries.map((entry) {
            return GestureDetector(
              onTap: () => setCurrentDetailNmId(entry.key),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: currentDetailNmId == entry.key ? 3 : 1,
                      color: currentDetailNmId == entry.key
                          ? Theme.of(context).primaryColor.withOpacity(0.7)
                          : Theme.of(context).colorScheme.primaryContainer),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ReWildNetworkImage(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  fit: BoxFit.cover,
                  image: entry.value,
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}

class _Efficiency extends StatelessWidget {
  const _Efficiency();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();

    final cpmRoiCorrelation = model.cpmRoiCorrelation;
    final cpmToCtrCorrelation = model.cpmCtrcorrelation;
    final notEnoughData = model.notEnoughData;
    final thresholdIsNotExceeded = model.thresholdIsNotExceeded;
    final totalCosts = model.totalCosts;
    final averageLogisticCost = model.averageLogisticCost;
    List<CampaignDataDay> selectedDays = model.selectedData;

    final currentDetailNmId = model.currentDetailNmId;
    if (currentDetailNmId != -1) {
      final getNmIdsSelectedData =
          model.getNmIdsSelectedData(currentDetailNmId);

      if (getNmIdsSelectedData != null) {
        selectedDays = getNmIdsSelectedData;
      }
    }
    model.setCorrelations(selectedDays);

    final goToCard = model.goToCard;

    final cpmToCtrRows = <(String, String)>[];

    if (notEnoughData) {
      cpmToCtrRows.add(
        (
          "Для точной оценки влияния ставки CPM на CTR (коэффициент кликабельности) используйте данные хотя бы за последние 30 дней.",
          ""
        ),
      );
    } else if (!thresholdIsNotExceeded && cpmRoiCorrelation != null) {
      cpmToCtrRows.addAll([
        (
          'Коэффициент корреляции Пирсона между ставкой CPM и CTR (коэффициент кликабельности): $cpmToCtrCorrelation',
          _correlationToText(context, cpmToCtrCorrelation ?? 0)
        ),
        (
          'Коэффициент корреляции Пирсона между ставкой CPM и ROMI (коэффициент окупаемости вложений в маркетинг): $cpmRoiCorrelation',
          _correlationToText(context, cpmRoiCorrelation)
        ),
        (
          _correlationPairsToText(
              context, cpmToCtrCorrelation!, cpmRoiCorrelation),
          ""
        )
      ]);
    } else if (thresholdIsNotExceeded) {
      cpmToCtrRows.add((
        'Для того чтобы оценка корреляции между ставкой CPM и другими показателями, такими как CTR (коэффициент кликабельности) или ROMI (коэффициент окупаемости вложений в маркетинг), была действительно значимой и информативной, необходимо, чтобы в рассматриваемом диапазоне данных ставка CPM демонстрировал достаточное изменение.',
        ""
      ));
    } else {
      const SizedBox(); // Fallback for an undefined state
    }

    // ROMI
    CampaignDataDay? selectedData = model.totalSelectedData;

    if (currentDetailNmId != -1) {
      selectedData = model.getNmIdsTotalSelectedData(currentDetailNmId);
    }
    // Total cost widget
    Widget? totalCostWidget;

    if (currentDetailNmId == -1) {
      // All tab is active
      for (final entry in totalCosts.entries) {
        // some of card may be empty
        if (entry.value!.expenses.isEmpty) {
          totalCostWidget = const GeneralUnitEconomicsNotification(
              text:
                  "Для точного расчета общего ROMI (коэффициент окупаемости вложений в маркетинг) необходимо заполнить данные о юнит-экономике всех номенклатур, учавствующих в кампании.");
          break;
        }
      }
      if (totalCostWidget == null) {
        // All cards are not empty
        if (selectedData == null) {
          return const SizedBox();
        }
        final profit = model.profit;
        final spend = selectedData.sum;
        final roi = (((profit - spend) / spend) * 100);
        final rows = [
          ('Доходы от маркетинга:', '${profit.round()} ₽'),
          ('Расходы на маркетинг:', '${spend.round()} ₽'),
          ('ROMI:', '${roi.round()}%'),
        ];
        totalCostWidget = CampaignSummaryWidget(
          rows: rows,
          title: 'Эффективность инвестиций:',
          success: roi >= 0,
        );
        // totalCostWidget = TotalCampaignSummaryWidget(
        //   summaryRevenue: profit,
        //   totalCampaignExpenses: spend,
        //   roi: roi,
        // );
      }
    }

    if (currentDetailNmId != -1) {
      // Some card is active
      final totalCost = totalCosts[currentDetailNmId];
      if (totalCost == null || totalCost.expenses.isEmpty) {
        totalCostWidget = UnitEconomicsNotificationBanner(
          onFillNowPressed: () => goToCard(currentDetailNmId),
        );
      } else {
        final grossProfit = totalCost.grossProfit;
        if (selectedData == null) {
          return const SizedBox();
        }
        final orders = selectedData.shks;
        final spend = selectedData.sum;
        final profit = orders * grossProfit(averageLogisticCost).round();
        final roi = (((profit - spend) / spend) * 100);
        final rows = [
          (
            'Средний доход на единицу товара:',
            '${grossProfit(averageLogisticCost).round()} ₽'
          ),
          ('Количество заказанных единиц:', '$orders шт.'),
          (
            profit > 0
                ? 'Общий доход на рекламную кампанию:'
                : 'Общий убыток на рекламную кампанию:',
            '${profit.round()} ₽'
          ),
          ('Общие затраты на рекламную кампанию:', '${spend.round()} ₽'),
          ('ROI:', '${roi.toStringAsFixed(0)}%'),
        ];

        totalCostWidget = CampaignSummaryWidget(
          rows: rows,
          success: roi >= 0,
          title: 'Эффективность инвестиций:',
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Анализ эффективности',
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        if (totalCostWidget != null) totalCostWidget,
        // if (notEnoughData)
        //   const GeneralUnitEconomicsNotification(
        //       text:
        //           'Для того чтобы оценка корреляции между CPM и другими показателями, такими как CTR или ROI, была действительно значимой и информативной, необходимо, чтобы в рассматриваемом диапазоне данных CPM демонстрировал достаточное изменение.'),
        // if (thresholdIsNotExceeded)
        //   const GeneralUnitEconomicsNotification(
        //       text:
        //           'Для того чтобы оценка корреляции между CPM и другими показателями, такими как CTR или ROI, была действительно значимой и информативной, необходимо, чтобы в рассматриваемом диапазоне данных CPM демонстрировал достаточное изменение.'),
        // if (!thresholdIsNotExceeded && !notEnoughData)
        CampaignSummaryWidget(
          title: 'Эффективность рекламных затрат',
          success: cpmToCtrCorrelation == null || cpmRoiCorrelation == null
              ? false
              : cpmToCtrCorrelation > 0.5 || cpmRoiCorrelation > 0.5,
          rows: cpmToCtrRows,
        ),
      ],
    );
  }

  String _correlationToText(BuildContext context, double correlation) {
    if (correlation >= 0.00 && correlation < 0.20) {
      return 'Очень слабая корреляция';
    } else if (correlation >= 0.20 && correlation < 0.39) {
      return 'Слабая корреляция';
    } else if (correlation >= 0.39 && correlation < 0.59) {
      return 'Средняя корреляция';
    } else if (correlation >= 0.59 && correlation < 0.80) {
      return 'Сильная корреляция';
    } else if (correlation >= 0.80 && correlation <= 1.00) {
      return 'Очень сильная корреляция';
    }
    return '';
  }

  String _correlationPairsToText(BuildContext context, double cpmCtrCorrelation,
      double cpmRoiCorrelation) {
    if (cpmCtrCorrelation >= 0.59 && cpmRoiCorrelation >= 0.59) {
      'Вывод: Рекламная кампания хорошо оптимизирована и целесообразно увеличивать её бюджет.';
    } else if (cpmCtrCorrelation >= 0.59 && cpmRoiCorrelation < 0.59) {
      return 'Вывод: увеличение стоимости показов и рост кликабельности не приводят к повышению возврата инвестиций. Проблема может заключаться в несоответствии содержания карточки товара ожиданиям покупателей или неэффективности выбранных параметров рекламной кампании.';
    } else if (cpmCtrCorrelation < 0.59 && cpmRoiCorrelation >= 0.59) {
      return 'Вывод: увеличение бюджета рекламной кампании приводит к более ценным конверсиям и улучшению ROI, это указывает на успешное привлечение качественного трафика, который более склонен к покупке';
    }
    return 'Вывод: повышение CPM не влияет на улучшение кликабельности (CTR) и возврата инвестиций (ROI), это может свидетельствовать о неэффективности текущих рекламных усилий на маркетплейсе. В такой ситуации целесообразно пересмотреть и оптимизировать рекламную стратегию.';
  }
}

class SoleCampaignData extends StatelessWidget {
  const SoleCampaignData({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();
    final startDate = model.selectedStartDate;
    final endDate = model.selectedEndDate;

    CampaignDataDay? totalSelectedData = model.totalSelectedData;
    final currentDetailNmId = model.currentDetailNmId;
    if (currentDetailNmId != -1) {
      totalSelectedData = model.getNmIdsTotalSelectedData(currentDetailNmId);
    }

    if (totalSelectedData == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        _buildMetricTile('Начало', startDate),
        _buildMetricTile('Конец', endDate),
        _buildMetricTile('ROI', '${totalSelectedData.roi.round()} %'),
        _buildMetricTile('Просмотры', totalSelectedData.views.toString()),
        _buildMetricTile('Клики', totalSelectedData.clicks.toString()),
        _buildMetricTile('CTR (%)', totalSelectedData.ctr.toStringAsFixed(2)),
        _buildMetricTile(
            'CPC', '${totalSelectedData.cpc.toStringAsFixed(2)} ₽'),
        _buildMetricTile(
            'Затраты', '${totalSelectedData.sum.toStringAsFixed(2)} ₽'),
        _buildMetricTile(
            'Добавлено в корзину', totalSelectedData.atbs.toString()),
        _buildMetricTile('Заказы', totalSelectedData.orders.toString()),
        _buildMetricTile('CR (%)', totalSelectedData.cr.toString()),
        _buildMetricTile('SHKS', totalSelectedData.shks.toString()),
        _buildMetricTile('Заказов на сумму',
            '${totalSelectedData.sumPrice.toStringAsFixed(2)} ₽'),
      ],
    );
  }

  Widget _buildMetricTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing:
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class MultiCampaignData extends StatelessWidget {
  const MultiCampaignData({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AdvertAnaliticsViewModel>();
    final selectedStartDate = model.selectedStartDate;
    final selectedEndDate = model.selectedEndDate;
    final previousStartDate = model.previousStartDate;
    final previousEndDate = model.previousEndDate;
    CampaignDataDay? selectedData = model.totalSelectedData;
    CampaignDataDay? previousData = model.totalPreviousData;
    final currentDetailNmId = model.currentDetailNmId;
    if (currentDetailNmId != -1) {
      selectedData = model.getNmIdsTotalSelectedData(currentDetailNmId);
      previousData = model.getNmIdsTotalPreviousData(currentDetailNmId);
    }
    final dynamicData = model.calculateDynamic(previousData, selectedData);

    if (selectedData == null || previousData == null || dynamicData == null) {
      return const SizedBox();
    }

    return AdvertMetricsDataTable(
      dynamicData: dynamicData,
      firstColHeaderDown: selectedEndDate,
      firstColHeaderUp: selectedStartDate,
      secondColHeaderDown: previousEndDate,
      secondColHeaderUp: previousStartDate,
      selectedData: selectedData,
      previousData: previousData,
    );
  }
}

class AdvertMetricsDataTable extends StatefulWidget {
  const AdvertMetricsDataTable(
      {super.key,
      required this.selectedData,
      required this.previousData,
      required this.dynamicData,
      required this.firstColHeaderDown,
      required this.secondColHeaderDown,
      required this.secondColHeaderUp,
      required this.firstColHeaderUp});
  final CampaignDataDay selectedData;
  final CampaignDataDay previousData;
  final Map<String, dynamic> dynamicData;

  final String firstColHeaderUp,
      firstColHeaderDown,
      secondColHeaderUp,
      secondColHeaderDown;

  @override
  State<AdvertMetricsDataTable> createState() => AdvertMetricsDataTableState();
}

class AdvertMetricsDataTableState extends State<AdvertMetricsDataTable> {
  @override
  Widget build(BuildContext context) {
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
            'ROAS',
            '${widget.selectedData.roi.round()} %',
            '${widget.previousData.roi.round()} %',
            '${widget.dynamicData['roiChange']}%',
          ),
          _createDataRow(
              'Затраты',
              '${widget.selectedData.sum.toStringAsFixed(0)} ₽',
              '${widget.previousData.sum.toStringAsFixed(0)} ₽',
              '${widget.dynamicData['sumChange']}%',
              true),
          _createDataRow(
            'Показатель кликабельности',
            '${widget.selectedData.ctr.toStringAsFixed(2)} %',
            '${widget.previousData.ctr.toStringAsFixed(2)} %',
            '${widget.dynamicData['ctrChange']}%',
          ),
          _createDataRow(
              'Показы',
              widget.selectedData.views.toString(),
              widget.previousData.views.toString(),
              '${widget.dynamicData['viewsChange'] ?? 0}%',
              true),
          _createDataRow(
            'Клики',
            widget.selectedData.clicks.toString(),
            widget.previousData.clicks.toString(),
            '${widget.dynamicData['clicksChange'] ?? 0}%',
          ),
          _createDataRow(
              'Добавлений в корзину',
              '${widget.selectedData.atbs}',
              '${widget.previousData.atbs}',
              '${widget.dynamicData['atbsChange'] ?? 0}%',
              true),
          _createDataRow(
            'Заказов',
            widget.selectedData.orders.toString(),
            widget.previousData.orders.toString(),
            '${widget.dynamicData['ordersChange'] ?? 0}%',
          ),
          _createDataRow(
              'Количество заказанных товаров',
              widget.selectedData.shks.toString(),
              widget.previousData.shks.toString(),
              '${widget.dynamicData['shksChange'] ?? 0}%',
              true),
          _createDataRow(
            'Заказов на сумму',
            '${widget.selectedData.sumPrice.toStringAsFixed(0)} ₽',
            '${widget.previousData.sumPrice.toStringAsFixed(0)} ₽',
            '${widget.dynamicData['sumPriceChange'] ?? 0}%',
          ),
          _createDataRow(
              'conversion rate',
              widget.selectedData.cr.toString(),
              widget.previousData.cr.toString(),
              '${widget.dynamicData['crChange'] ?? 0}%',
              true),
          _createDataRow(
            'Средняя стоимость клика',
            '${widget.selectedData.cpc.toStringAsFixed(2)} ₽',
            '${widget.previousData.cpc.toStringAsFixed(2)} ₽',
            '${widget.dynamicData['cpcChange'] ?? 0}%',
          ),
          _createDataRow(
            'Стоимость заказа',
            '${(widget.selectedData.sum / widget.selectedData.orders).ceil()} ₽',
            '${(widget.previousData.sum / widget.previousData.orders).ceil()} ₽',
            '${widget.dynamicData['costPerOrderChange']}%',
          ),
        ],
      ),
    );
  }

  DataRow _createDataRow(String metric, String selectedValue,
      String previousValue, String comparison,
      [bool isEven = false]) {
    Color color = const Color(0xFF007c32);
    if (comparison.startsWith("-")) {
      if (metric == 'Средняя стоимость клика' || metric == 'Стоимость заказа') {
        color = const Color(0xFF007c32);
      } else {
        color = Colors.red;
      }
    } else {
      if (metric != 'Средняя стоимость клика') {
        color = const Color(0xFF007c32);
      } else {
        color = Colors.red;
      }
    }
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (isEven) {
          return Theme.of(context).colorScheme.background;
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
              maxLines: 2,
            ))),
        DataCell(SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              previousValue,
              textAlign: TextAlign.center,
              maxLines: 2,
            ))),
        DataCell(SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              comparison,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  color: comparison == "0%" ||
                          metric == 'Затраты' ||
                          metric == 'ROI'
                      ? null
                      : color),
            ))),
      ],
    );
  }
}

class CampaignMetricsChart extends StatefulWidget {
  final List<CampaignDataDay> dataDays;

  const CampaignMetricsChart({super.key, required this.dataDays});

  @override
  State<CampaignMetricsChart> createState() => _CampaignMetricsChartState();
}

class _CampaignMetricsChartState extends State<CampaignMetricsChart> {
  @override
  Widget build(BuildContext context) {
    List<FlSpot> ctrSpots = [];

    List<String> dates = [];
    for (var i = 0; i < widget.dataDays.length; i++) {
      final day = widget.dataDays[i];
      final date = day.date;
      final xValue = i.toDouble();

      ctrSpots.add(FlSpot(xValue, double.parse(day.ctr.toStringAsFixed(1))));

      dates.add(date);
    }

    final newViews = widget.dataDays.last.views;
    final newClicks = widget.dataDays.last.clicks;

    double newCtr =
        double.parse(((newClicks / newViews) * 100).toStringAsFixed(1));
    if (ctrSpots.isNotEmpty && newViews > 0) {
      double lastXValue = ctrSpots.last.x;
      ctrSpots[ctrSpots.length - 1] = FlSpot(lastXValue, newCtr);
    }

    return Column(
      children: [
        _buildLineChart('CTR, %', ctrSpots, dates),
        const SizedBox(height: 20),
        _buildBarChart(
            'Просмотры',
            widget.dataDays.map((e) => e.views.toDouble()).toList(),
            widget.dataDays),
        const SizedBox(height: 20),
        _buildBarChart(
            'Клики',
            widget.dataDays.map((e) => e.clicks.toDouble()).toList(),
            widget.dataDays),
        const SizedBox(height: 20),
        _buildBarChart(
            'Заказы',
            widget.dataDays.map((e) => e.orders.toDouble()).toList(),
            widget.dataDays),
      ],
    );
  }

  Widget _buildBarChart(
      String title, List<double> values, List<CampaignDataDay> days) {
    final barWidth =
        _calculateBarWidth(values.length); // Вычисляем ширину столбца

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < values.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: values[i],
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(3),
                width: barWidth),
          ],
          showingTooltipIndicators: [],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: values.reduce(max),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (_, __, rod, ___) {
                    return BarTooltipItem(
                      rod.toY.toString(),
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final isShowTitle =
                          values.length > 15 ? value.toInt() % 5 == 0 : true;
                      if (isShowTitle && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -pi / 180 * 90,
                            child: Text(
                              DateFormat('dd.MM').format(
                                  DateTime.parse(days[value.toInt()].date)),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        return const Text('');
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateBarWidth(int itemCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.7 / itemCount;
  }

  Widget _buildLineChart(String title, List<FlSpot> spots, List<String> dates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final isShowTitle =
                            dates.length > 15 ? value.toInt() % 5 == 0 : true;
                        if (isShowTitle && value.toInt() < dates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -pi / 180 * 90,
                              child: Text(
                                DateFormat('dd.MM').format(
                                    DateTime.parse(dates[value.toInt()])),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UnitEconomicsNotificationBanner extends StatelessWidget {
  final VoidCallback onFillNowPressed;

  const UnitEconomicsNotificationBanner(
      {super.key, required this.onFillNowPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Для расчета ROI с учетом дохода на единицу товара необходимо заполнить данные о Ваших расходах.",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: onFillNowPressed,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text("Заполнить сейчас"),
          ),
        ],
      ),
    );
  }
}

class GeneralUnitEconomicsNotification extends StatelessWidget {
  const GeneralUnitEconomicsNotification({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// class TotalCampaignSummaryWidget extends StatelessWidget {
//   final double summaryRevenue;

//   final double totalCampaignExpenses;
//   final double roi;

//   const TotalCampaignSummaryWidget({
//     super.key,
//     required this.summaryRevenue,
//     required this.totalCampaignExpenses,
//     required this.roi,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'ROI:',
//               style: Theme.of(context).textTheme.headline6,
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow(
//                 context, 'Общий доход:', '${summaryRevenue.round()} ₽'),
//             _buildInfoRow(context, 'Общие затраты на рекламную кампанию:',
//                 '${totalCampaignExpenses.round()} ₽'),
//             _buildInfoRow(context, 'ROI:', '${roi.toStringAsFixed(0)}%'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: TextStyle(color: Theme.of(context).colorScheme.secondary),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CampaignSummaryWidget extends StatelessWidget {
  final List<(String, String)> rows;

  final String title;
  final bool success;

  const CampaignSummaryWidget({
    super.key,
    required this.rows,
    required this.title,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: success
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer),
            ),
            const SizedBox(height: 16),
            ...rows.map((row) => _buildInfoRow(context, row.$1, row.$2)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
                color: success
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}

class CpmToCtrWidget extends StatelessWidget {
  final bool notEnoughData;
  final bool thresholdIsNotExceeded;
  final double? correlation;
  final double? cpmRoiCorrelation;

  const CpmToCtrWidget({
    super.key,
    required this.notEnoughData,
    required this.thresholdIsNotExceeded,
    this.correlation,
    this.cpmRoiCorrelation,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (notEnoughData) {
      content = const GeneralUnitEconomicsNotification(
        text:
            "Для точной оценки влияния CPC на CTR используйте данные хотя бы за последние 30 дней.",
      );
    } else if (!thresholdIsNotExceeded &&
        correlation != null &&
        cpmRoiCorrelation != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('Коэффициент корреляции Пирсона между CPM и CTR: $correlation',
              style: Theme.of(context).textTheme.titleSmall),
          // const SizedBox(height: 5),
          // _correlationToText(context, correlation!),
          // Text(
          //     'Коэффициент корреляции Пирсона между CPM и ROI: $cpmRoiCorrelation',
          //     style: Theme.of(context).textTheme.subtitle1),
          // const SizedBox(height: 5),
          // _correlationToText(context, cpmRoiCorrelation!),
          // const SizedBox(height: 5),
          // _correlationPairsToText(context, correlation!, cpmRoiCorrelation!),
        ],
      );
    } else if (thresholdIsNotExceeded) {
      content = const Text(
          'Для того чтобы оценка корреляции между CPM и другими показателями, такими как CTR или ROI, была действительно значимой и информативной, необходимо, чтобы в рассматриваемом диапазоне данных CPM демонстрировал достаточное изменение.');
    } else {
      content = const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}
