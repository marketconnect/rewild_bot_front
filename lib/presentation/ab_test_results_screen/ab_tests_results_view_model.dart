import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/ab_test.dart';
import 'package:rewild_bot_front/domain/entities/fetch_analitics_detail_result.dart';
import 'package:screenshot/screenshot.dart';

abstract class ABTestsResultsViewModelAnalyticsDetailService {
  Future<Either<RewildError, FetchDetailResult>> fetchDetail({
    required DateTime begin,
    required DateTime end,
    int? page,
    List<int>? nmIds,
  });
  Future<Either<RewildError, bool>> apiKeyExists();
}

abstract class ABTestsResultsCardsService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// abstract class ABTestsResultsABTestsService {
//   Future<Either<RewildError, ABTest>> getABTestById(int id);
// }

class ABTestsResultsViewModel extends ResourceChangeNotifier {
  final ABTestsResultsViewModelAnalyticsDetailService analiticsDetailService;
  // final ABTestsResultsABTestsService abTestsService;
  final ABTestsResultsCardsService cardsService;

  ABTestsResultsViewModel(
      {required super.context,
      required this.analiticsDetailService,
      // required this.abTestsService,
      required this.cardsService,
      required ABTest inputAbTest})
      : _abTest = inputAbTest,
        super() {
    _asyncInit();
  }

  _asyncInit() async {
    _setIsLoading(true);
    // check api key
    final apiKey = await fetch(() => analiticsDetailService.apiKeyExists());
    if (apiKey == null || !apiKey) {
      setApiKeyExists(false);
    } else {
      setApiKeyExists(true);
    }
    // test
    // final abTest = await fetch(() => abTestsService.getABTestById(id));
    // if (abTest == null) {
    //   _setIsLoading(false);
    //   return;
    // }
    // _setAbTest(abTest);

    // analytics
    final result = await fetch(() => analiticsDetailService.fetchDetail(
        nmIds: [abTest.nmId],
        begin: fromIso8601String(abTest.startDate),
        end: fromIso8601String(abTest.endDate)));
    if (result == null) {
      _setIsLoading(false);
      return;
    }
    _setAnaliticsDetail(result.details.first);
    // image
    final image =
        await fetch(() => cardsService.getImageForNmId(nmId: abTest.nmId));
    if (image == null) {
      _setIsLoading(false);
      return;
    }
    _setImage(image);
    _setIsLoading(false);
  }

  // loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void _setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  // Api key exists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool apiKeyExists) {
    _apiKeyExists = apiKeyExists;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;

  // ab test
  // ignore: prefer_final_fields
  ABTest _abTest;
  ABTest get abTest => _abTest;
  // void _setAbTest(ABTest value) {
  //   _abTest = value;
  //   notify();
  // }

  // image
  String? _image;
  String? get image => _image;
  void _setImage(String value) {
    _image = value;
    notify();
  }

  // fetched details
  AnaliticsDetail? _analiticsDetail;
  AnaliticsDetail? get analiticsDetail => _analiticsDetail;
  void _setAnaliticsDetail(AnaliticsDetail value) {
    _analiticsDetail = value;
    notify();
  }

  // PDF
  final aBTestSummaryScreenController = ScreenshotController();

  final labesABColorsScreenController = ScreenshotController();
  final firstRowScreenshotController = ScreenshotController();
  final secondRowScreenshotController = ScreenshotController();
  final thirdRowScreenshotController = ScreenshotController();

  Future<Uint8List?> captureABTestSummary() async {
    return aBTestSummaryScreenController.capture();
  }

  Future<Uint8List?> captureLabesABColors() async {
    return labesABColorsScreenController.capture();
  }

  Future<Uint8List?> captureFirstRow() async {
    return firstRowScreenshotController.capture();
  }

  Future<Uint8List?> captureSecondRow() async {
    return secondRowScreenshotController.capture();
  }

  Future<Uint8List?> captureThirdRow() async {
    return thirdRowScreenshotController.capture();
  }

  List<List<String>> prepareDataTable(AnaliticsDetail analyticsDetail) {
    return [
      [
        'Переходов в карточку',
        analyticsDetail.statistics.selectedPeriod.openCardCount.toString(),
        analyticsDetail.statistics.previousPeriod.openCardCount.toString(),
        '${analyticsDetail.statistics.periodComparison.openCardDynamics}%',
      ],
      [
        'Добавлений в корзину',
        analyticsDetail.statistics.selectedPeriod.addToCartCount.toString(),
        analyticsDetail.statistics.previousPeriod.addToCartCount.toString(),
        '${analyticsDetail.statistics.periodComparison.addToCartDynamics}%',
      ],
      [
        'Заказов',
        analyticsDetail.statistics.selectedPeriod.ordersCount.toString(),
        analyticsDetail.statistics.previousPeriod.ordersCount.toString(),
        '${analyticsDetail.statistics.periodComparison.ordersCountDynamics}%',
      ],
      [
        'Заказов на сумму',
        '${analyticsDetail.statistics.selectedPeriod.ordersSumRub} р',
        '${analyticsDetail.statistics.previousPeriod.ordersSumRub} р',
        '${analyticsDetail.statistics.periodComparison.ordersSumRubDynamics}%',
      ],
      [
        'Выкупили',
        analyticsDetail.statistics.selectedPeriod.buyoutsCount.toString(),
        analyticsDetail.statistics.previousPeriod.buyoutsCount.toString(),
        '${analyticsDetail.statistics.periodComparison.buyoutsCountDynamics}%',
      ],
      [
        'Выкупили на сумму',
        '${analyticsDetail.statistics.selectedPeriod.buyoutsSumRub} р',
        '${analyticsDetail.statistics.previousPeriod.buyoutsSumRub} р',
        '${analyticsDetail.statistics.periodComparison.buyoutsSumRubDynamics}%',
      ],
      [
        'Отменили товаров',
        analyticsDetail.statistics.selectedPeriod.cancelCount.toString(),
        analyticsDetail.statistics.previousPeriod.cancelCount.toString(),
        '${analyticsDetail.statistics.periodComparison.cancelCountDynamics}%',
      ],
      [
        'Отменили на сумму',
        '${analyticsDetail.statistics.selectedPeriod.cancelSumRub} р',
        '${analyticsDetail.statistics.previousPeriod.cancelSumRub} р',
        '${analyticsDetail.statistics.periodComparison.cancelSumRubDynamics}%',
      ],
      [
        'Средняя цена',
        '${analyticsDetail.statistics.selectedPeriod.avgPriceRub} р',
        '${analyticsDetail.statistics.previousPeriod.avgPriceRub} р',
        '${analyticsDetail.statistics.periodComparison.avgPriceRubDynamics}%',
      ],
      [
        'Ср. кол-во заказов в день',
        analyticsDetail.statistics.selectedPeriod.avgOrdersCountPerDay
            .toStringAsFixed(2),
        analyticsDetail.statistics.previousPeriod.avgOrdersCountPerDay
            .toStringAsFixed(2),
        '${analyticsDetail.statistics.periodComparison.avgOrdersCountPerDayDynamics}%',
      ],
      [
        'Конверсия в корзину, %',
        '${analyticsDetail.statistics.selectedPeriod.conversions.addToCartPercent.toStringAsFixed(2)}%',
        '${analyticsDetail.statistics.previousPeriod.conversions.addToCartPercent.toStringAsFixed(2)}%',
        '${analyticsDetail.statistics.periodComparison.conversions.addToCartPercent}%',
      ],
      [
        'Конверсия в заказ, %',
        '${analyticsDetail.statistics.selectedPeriod.conversions.cartToOrderPercent.toStringAsFixed(2)}%',
        '${analyticsDetail.statistics.previousPeriod.conversions.cartToOrderPercent.toStringAsFixed(2)}%',
        '${analyticsDetail.statistics.periodComparison.conversions.cartToOrderPercent}%',
      ],
      [
        'Процент выкупа, %',
        '${analyticsDetail.statistics.selectedPeriod.conversions.buyoutsPercent.toStringAsFixed(2)}%',
        '${analyticsDetail.statistics.previousPeriod.conversions.buyoutsPercent.toStringAsFixed(2)}%',
        '${analyticsDetail.statistics.periodComparison.conversions.buyoutsPercent}%',
      ],
    ];
  }

  Future<void> generateAndSavePdf(
      ABTest abTest, AnaliticsDetail analyticsDetail) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final aBTestSummary = await captureABTestSummary();
    final labesABColors = await captureLabesABColors();
    final firstRow = await captureFirstRow();
    final secondRow = await captureSecondRow();
    final thirdRow = await captureThirdRow();

    if (firstRow != null &&
        secondRow != null &&
        thirdRow != null &&
        aBTestSummary != null &&
        labesABColors != null) {
      final aBTestSummaryPdf = pw.MemoryImage(aBTestSummary);
      final labesABColorsPdf = pw.MemoryImage(labesABColors);
      final firstRowPdf = pw.MemoryImage(firstRow);
      final secondRowPdf = pw.MemoryImage(secondRow);
      final thirdRowPdf = pw.MemoryImage(thirdRow);
      final headers = ['Метрика', 'Версия B', 'Версия A', 'Динамика'];

      final data = prepareDataTable(analyticsDetail);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                pw.Image(aBTestSummaryPdf),
              ],
            );
          },
        ),
      );
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 20),
                  pw.Text('Метрики теста',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 30, font: ttf)),
                  pw.SizedBox(height: 20),
                  pw.TableHelper.fromTextArray(
                    headers: headers,
                    data: data,
                    headerStyle:
                        pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    cellStyle: pw.TextStyle(font: ttf),
                    cellHeight: 30,
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.centerRight,
                      2: pw.Alignment.centerRight,
                      3: pw.Alignment.centerRight,
                    },
                  )
                ]);
          },
        ),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                // Add image to PDF
                pw.Image(firstRowPdf),
                // Add text to PDF

                pw.SizedBox(height: 20),
                pw.Image(labesABColorsPdf),
              ],
            );
          },
        ),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                // Add image to PDF
                pw.Image(secondRowPdf),
                // Add text to PDF

                pw.SizedBox(height: 20),
                pw.Image(labesABColorsPdf),
              ],
            );
          },
        ),
      );
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                // Add image to PDF
                pw.Image(thirdRowPdf),
                // Add text to PDF

                pw.SizedBox(height: 20),
                pw.Image(labesABColorsPdf),
              ],
            );
          },
        ),
      );
    }

    // Save and share PDF
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'ABTestResults.pdf');
  }
}
