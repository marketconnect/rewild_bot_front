import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/color.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/presentation/home/report_screen/report_view_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportViewModel>();

    final isLoading = model.isLoading;
    final isApiKeyExists = model.apiKeyExists;
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Отчет'),
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),
        body: isApiKeyExists
            ? const SingleChildScrollView(
                child: Column(
                  children: [
                    RealizationReportWidget(),
                  ],
                ),
              )
            : const _EmptyApiKeyWidget(),
      ),
    );
  }
}

class _EmptyApiKeyWidget extends StatelessWidget {
  const _EmptyApiKeyWidget();

  @override
  Widget build(BuildContext context) {
    final addToken = context.read<ReportViewModel>().addToken;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EmptyWidget(
            text:
                'Для работы с отчетами WB вам необходимо добавить токен "Статистика"'),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        TextButton(
            onPressed: () => addToken(),
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                )))
      ],
    ));
  }
}

class RealizationReportWidget extends StatefulWidget {
  const RealizationReportWidget({super.key});

  @override
  State<RealizationReportWidget> createState() =>
      _RealizationReportWidgetState();
}

class _RealizationReportWidgetState extends State<RealizationReportWidget> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportViewModel>();
    final reports = model.reports;
    final dateFrom = model.dateFrom;
    final dateTo = model.dateTo;
    final fetchReports = model.fetchData;

    if (reports.isEmpty && dateFrom.isEmpty && dateTo.isEmpty) {
      return CustomElevatedButton(
        onTap: () {
          _showWeekPicker();
        },
        text: "Выберите период",
        buttonStyle: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary,
            ),
            foregroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.onPrimary)),
        height: model.screenWidth * 0.2,
        margin: EdgeInsets.fromLTRB(
            model.screenWidth * 0.1,
            model.screenHeight * 0.4,
            model.screenWidth * 0.1,
            model.screenHeight * 0.4),
      );
    } else if (dateFrom.isNotEmpty && dateTo.isNotEmpty && reports.isEmpty) {
      final isMondayFrom3To16 = model.isMondayFrom3To16();
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            onPressed: () => _showWeekPicker(),
            child: SizedBox(
              width: model.screenWidth * 0.8,
              child: Text(
                'Выбран период с $dateFrom по $dateTo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          CustomElevatedButton(
            onTap: () async => await fetchReports(),
            text: "Сформировать отчет",
            buttonStyle: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary)),
            height: model.screenWidth * 0.2,
            margin: EdgeInsets.fromLTRB(
                model.screenWidth * 0.1,
                model.screenHeight * 0.05,
                model.screenWidth * 0.1,
                model.screenHeight * 0.05),
          ),
          if (isMondayFrom3To16)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  '* Технический перерыв в работе метода: каждый понедельник с 3:00 до 16:00.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
        ]),
      );
    } else if (reports.isNotEmpty) {
      return const RealizationSummaryWidget();
    }
    return Container();
  }

  void _showWeekPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _WeekPicker(buildContext: context),
    );
  }
}

// class _WeekPicker extends StatelessWidget {
//   const _WeekPicker({required this.buildContext});
//   final BuildContext buildContext;

//   List<DateTime> getWeeks(DateTime start, DateTime end) {
//     List<DateTime> weeks = [];
//     DateTime tempDate = start;

//     tempDate = tempDate.subtract(Duration(days: tempDate.weekday - 1));

//     while (tempDate.isBefore(end)) {
//       weeks.add(tempDate);
//       tempDate = tempDate.add(const Duration(days: 7));
//     }
//     return weeks.reversed.toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = buildContext.watch<ReportViewModel>();
//     final setInterval = model.setInterval;

//     DateTime now = DateTime.now();
//     DateTime today = DateTime(now.year, now.month, now.day);
//     DateTime endOfLastFullWeek = today.subtract(Duration(days: today.weekday));
//     DateTime start = today.subtract(const Duration(days: 90));

//     // // since WB updated the API method and now it returns storage_fee
//     // // too and it works only after 29.01.2024
//     // if (start.isBefore(DateTime(2024, 1, 29))) {
//     //   start = DateTime(2024, 1, 29);
//     // }
//     List<DateTime> weeks = getWeeks(start, endOfLastFullWeek);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Выберите период'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: ListView.separated(
//           itemCount: weeks.length,
//           separatorBuilder: (context, index) => const Divider(),
//           itemBuilder: (context, index) {
//             DateTime weekStart = weeks[index];
//             DateTime weekEnd = weekStart.add(const Duration(days: 6));

//             String weekRange =
//                 "${DateFormat('dd.MM.yyyy').format(weekStart)} - ${DateFormat('dd.MM.yyyy').format(weekEnd)}";

//             return ListTile(
//               title: Text(weekRange),
//               leading: const Icon(Icons.date_range),
//               trailing: const Icon(Icons.keyboard_arrow_right),
//               onTap: () {
//                 setInterval(weekStart);
//                 Navigator.of(context).pop();
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

class _WeekPicker extends StatefulWidget {
  const _WeekPicker({required this.buildContext});
  final BuildContext buildContext;

  @override
  _WeekPickerState createState() => _WeekPickerState();
}

class _WeekPickerState extends State<_WeekPicker> {
  List<DateTime> selectedWeeks = [];

  List<DateTime> getWeeks(DateTime start, DateTime end) {
    List<DateTime> weeks = [];
    DateTime tempDate = start;

    tempDate = tempDate.subtract(Duration(days: tempDate.weekday - 1));

    while (tempDate.isBefore(end)) {
      weeks.add(tempDate);
      tempDate = tempDate.add(const Duration(days: 7));
    }
    return weeks.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.buildContext.watch<ReportViewModel>();
    final setInterval = model.setInterval;

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime endOfLastFullWeek = today.subtract(Duration(days: today.weekday));
    DateTime start = today.subtract(const Duration(days: 90));

    List<DateTime> weeks = getWeeks(start, endOfLastFullWeek);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Выберите период'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.separated(
          itemCount: weeks.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            DateTime weekStart = weeks[index];
            DateTime weekEnd = weekStart.add(const Duration(days: 6));

            String weekRange =
                "${DateFormat('dd.MM.yyyy').format(weekStart)} - ${DateFormat('dd.MM.yyyy').format(weekEnd)}";

            return ListTile(
              title: Text(weekRange),
              leading: const Icon(Icons.date_range),
              trailing: Checkbox(
                value: selectedWeeks.contains(weekStart),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedWeeks.add(weekStart);
                    } else {
                      selectedWeeks.remove(weekStart);
                    }
                  });
                },
              ),
              onTap: () {
                setState(() {
                  if (selectedWeeks.contains(weekStart)) {
                    selectedWeeks.remove(weekStart);
                  } else {
                    selectedWeeks.add(weekStart);
                  }
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedWeeks.isNotEmpty) {
            setInterval(
                selectedWeeks); // You can handle multiple weeks here as needed
            Navigator.of(context).pop();
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class RealizationSummaryWidget extends StatefulWidget {
  const RealizationSummaryWidget({
    super.key,
  });

  @override
  State<RealizationSummaryWidget> createState() =>
      _RealizationSummaryWidgetState();
}

class _RealizationSummaryWidgetState extends State<RealizationSummaryWidget> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportViewModel>();
    final dataMap = model.getRevenueDistributionWithImages();
    List<Color>? colorList = model.colors;
    colorList ??= generateRandomColors(dataMap.length);
    final isProfitDestributionActive = model.isProfitDestributionActive;
    final reportId = model.reportId;
    final salesNum = model.salesNum;
    final returnsNum = model.returnsNum;
    final revenue = model.revenue;
    final totalRevenue = model.totalRevenue;
    final wbCommission = model.wbCommission;
    final delivery = model.delivery;
    final storage = model.storage;
    final advSpentFromBalance = model.advSpentFromBalance;
    final deduction = model.deduction;
    final penalties = model.penalties;
    final additionalPayment = model.additionalPayment;
    final cogsSum = model.cogsSum;
    final tax = model.tax;
    final taxValue = model.taxValue;
    final expensesAndOthers = model.expensesAndOthers;
    final profit = model.profit;
    final profitabilityOfSales = model.profitabilityOfSales;
    final images = model.images;
    final emptyCogs = model.emptyCogs;
    final dateFrom = model.dateFrom;
    final dateTo = model.dateTo;
    final currentDetailNmId = model.currentDetailNmId;
    final minPpvzForPay = model.minPpvzForPay;
    final minPpvzForPayWarehouse = model.minPpvzForPayWarehouse;
    final pay = model.pay;
    final advertExpenses = model.advertExpenses;
    final ebitda = model.ebitda;

    final rows = [
      (
        const Text('Продаж'),
        Text('$salesNum шт.'),
      ),
      if (returnsNum > 0)
        (
          const Text('Возвратов'),
          Text('$returnsNum шт.'),
        ),
      if (minPpvzForPay > 0)
        (
          const Text('Наименьшая выручка с продажи'),
          Text(
            '${minPpvzForPay.toStringAsFixed(2)} ₽',
          ),
        ),
      if (minPpvzForPayWarehouse.isNotEmpty)
        (
          const Text('Склад'),
          Text(
            minPpvzForPayWarehouse,
          ),
        ),
      (
        const Text('Выручка', style: TextStyle(fontWeight: FontWeight.w600)),
        Text('${revenue.toStringAsFixed(2)} ₽',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      if (currentDetailNmId != -1)
        (
          const Text('Доля в общей выручке',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Text('${((revenue / totalRevenue) * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      (
        Container(),
        Container(),
      ),
      (
        const Text('Комиссия WB'),
        Text('${wbCommission.toStringAsFixed(2)} ₽'),
      ),
      (
        const Text('Стоимость логистики'),
        Text('${delivery.toStringAsFixed(2)} ₽'),
      ),
      if (currentDetailNmId == -1)
        (
          const Text('Стоимость хранения'),
          Text('${storage.toStringAsFixed(2)} ₽'),
        ),
      if (advSpentFromBalance != 0)
        (
          const Text('Продвижение с баланса'),
          Text('${advSpentFromBalance.toStringAsFixed(2)} ₽'),
        ),
      if (penalties != 0)
        (
          const Text('Штрафы'),
          Text('${penalties.toStringAsFixed(2)} ₽'),
        ),
      if (additionalPayment != 0)
        (
          const Text('Доплаты'),
          Text('${additionalPayment.toStringAsFixed(2)} ₽'),
        ),
      if (deduction != 0)
        (
          const Text('Удержания'),
          Text('${deduction.toStringAsFixed(2)} ₽'),
        ),
      (
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Text('Расходы и удержания к выручке'),
        ),
        Text(
            '${revenue == 0 ? 0 : (expensesAndOthers * 100 / revenue).toStringAsFixed(0)} %'),
      ),
      (
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Text('Общая сумма',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text('${expensesAndOthers.toStringAsFixed(2)} ₽',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      (Container(), Container()),
      (
        const Text('К перечислению '),
        Text('${pay.toStringAsFixed(2)} ₽'),
      ),
      if (currentDetailNmId == -1 && advertExpenses > 0)
        (
          const Text('Траты на рекламу'),
          Text('${advertExpenses.toStringAsFixed(2)} ₽'),
        ),
      (
        const Text('Себестоимость'),
        Text(
          '${cogsSum.toStringAsFixed(2)} ₽',
          maxLines: 2,
          style: TextStyle(
            color: (currentDetailNmId == -1 && emptyCogs.isNotEmpty) ||
                    cogsSum == 0
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        ),
      ),
      if (currentDetailNmId == -1)
        (
          const Text('EBITDA'),
          Text('${ebitda.toStringAsFixed(2)} ₽'),
        ),
      (
        Text('Налог ${tax.toStringAsFixed(0)}%'),
        Text(
          '${taxValue.toStringAsFixed(2)} ₽',
          style: TextStyle(
            color: tax == 0 ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ),
      if (currentDetailNmId == -1)
        (
          const Text('Рентабельность продаж'),
          Text('${profitabilityOfSales.toStringAsFixed(2)}%'),
        ),
      (
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Text('Прибыль', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text('${profit.toStringAsFixed(2)} ₽',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: HorizontalProductImages(),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Отчет: ${reportId == 0 ? 'несколько' : reportId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          InkWell(
            onTap: () => _showWeekPicker(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'С $dateFrom по $dateTo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const Divider(),
          _DataTable(rows: rows),
          if (currentDetailNmId != -1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                '* Стоимость хранения и расходы на рекламу не учитываются.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          if (currentDetailNmId == -1 && advertExpenses <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                '* Расходы на рекламу не учитываются.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          if (dataMap.isNotEmpty && currentDetailNmId == -1)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Распределение ${isProfitDestributionActive ? 'прибыли' : 'выручки'}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: PieChart(
                    dataMap: {
                      for (var entry in dataMap.entries)
                        entry.key: isProfitDestributionActive
                            ? entry.value.$2 * 100
                            : entry.value.$1 * 100
                    },
                    chartType: ChartType.disc,
                    chartRadius: MediaQuery.of(context).size.width / 2.7,
                    colorList: colorList, // Generate random colors
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: false,
                    ),
                    legendOptions: const LegendOptions(
                      showLegends: false, // Hide the default legend
                    ),
                  ),
                ),
                CustomLegend(data: dataMap, colorList: colorList),
              ],
            ),
        ],
      ),
    );
  }

  void _showWeekPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _WeekPicker(buildContext: context),
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({
    required this.rows,
  });

  final List<(Widget, Widget)> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 0,
      horizontalMargin: 0,
      dividerThickness: 0,
      columns: [
        DataColumn(
            label: SizedBox(
                child: Text('Показатель',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.055,
                        fontWeight: FontWeight.bold)))),
        DataColumn(
            label: Text('Значение',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.055,
                    fontWeight: FontWeight.bold))),
      ],
      rows: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;
        // final header = row.$1 is Container;
        return DataRow(
          color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (index % 2 != 0 ||
                (row.$1 is Container && row.$2 is Container)) {
              return null;
            }
            return const Color(0xFFF8F9FA);
          }),
          cells: [DataCell(row.$1), DataCell(row.$2)],
        );
      }).toList(),
    );
  }
}

class HorizontalProductImages extends StatelessWidget {
  const HorizontalProductImages({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportViewModel>();
    final currentDetailNmId = model.currentDetailNmId;
    final setCurrentDetailNmId = model.setCurrentDetailNmId;
    final images = model.images;

    final emptyCogs = model.emptyCogs;
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
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'По всем',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          ...images.entries.map((entry) {
            final nmId = entry.key;
            final withoutCogs = emptyCogs.contains(nmId);
            return GestureDetector(
              onTap: () => setCurrentDetailNmId(entry.key),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: currentDetailNmId == entry.key ? 3 : 1,
                          color: currentDetailNmId == entry.key
                              ? Theme.of(context).primaryColor.withOpacity(0.7)
                              : Theme.of(context).colorScheme.primaryContainer),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: ReWildNetworkImage(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      fit: BoxFit.cover,
                      image: entry.value.$1,
                    ),
                  ),
                  if (withoutCogs)
                    Positioned(
                        top: currentDetailNmId == entry.key
                            ? MediaQuery.of(context).size.width * 0.07 + 3
                            : MediaQuery.of(context).size.width * 0.07,
                        left: currentDetailNmId == entry.key ? 9 : 6,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Нет",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    color: Theme.of(context).colorScheme.error,
                                  )),
                              Text("данных",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    color: Theme.of(context).colorScheme.error,
                                  )),
                            ],
                          ),
                        )),
                  if (currentDetailNmId == entry.key)
                    Positioned(
                        bottom: MediaQuery.of(context).size.width * 0.07 + 3,
                        left: MediaQuery.of(context).size.width * 0.07 + 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )),
                ],
              ),
            );
          }),
        ]),
      ),
    );
  }
}

class CustomLegend extends StatefulWidget {
  final Map<String, (double, double, String, bool)>
      data; // Update data to include both revenue and profit
  final List<Color> colorList;

  const CustomLegend({required this.data, required this.colorList, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomLegendState createState() => _CustomLegendState();
}

class _CustomLegendState extends State<CustomLegend> {
  // bool showProfit = false; // State to toggle between profit and revenue

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReportViewModel>();
    final setCurrentDetailNmId = model.setCurrentDetailNmId;
    final isProfitDestributionActive = model.isProfitDestributionActive;
    final setIsRevenueDestributionActive = model.setIsRevenueDestributionActive;
    int colorIndex = 0;
    double totalTopContributorPercentage = 0;
    int lastTopContributorIndex = -1;

    // Calculate total percentage of top contributors and find the index of the last top contributor
    final List<MapEntry<String, (double, double, String, bool)>> entries =
        widget.data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].value.$4) {
        // Check if it's a top contributor
        totalTopContributorPercentage += (isProfitDestributionActive
                ? entries[i].value.$2
                : entries[i].value.$1) *
            100;
        lastTopContributorIndex = i;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                selectedColor: Colors.white,
                fillColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.onSurface,
                isSelected: [
                  !isProfitDestributionActive,
                  isProfitDestributionActive
                ],
                onPressed: (int index) {
                  setIsRevenueDestributionActive(index == 1);
                },
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Выручка'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Прибыль'),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final nmId = entry.value.key;
          final revenue = entry.value.value.$1;
          final profit = entry.value.value.$2;
          final imageUrl = entry.value.value.$3;
          final isTopContributor = entry.value.value.$4;
          final color = widget.colorList[colorIndex % widget.colorList.length];
          colorIndex++;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    final nmIdInt = int.tryParse(nmId);
                    if (nmIdInt != null) {
                      setCurrentDetailNmId(nmIdInt);
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ReWildNetworkImage(
                              width: 40,
                              height: 40,
                              image: imageUrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nmId,
                                  style: TextStyle(
                                    fontWeight: isTopContributor
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isTopContributor
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${((isProfitDestributionActive ? profit : revenue) * 100).toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isTopContributor)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Insert the total percentage after the last top contributor
              if (index == lastTopContributorIndex)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                        ),
                        child: Text(
                          '${totalTopContributorPercentage.toStringAsFixed(0)}% ${isProfitDestributionActive ? 'прибыли' : 'выручки'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
