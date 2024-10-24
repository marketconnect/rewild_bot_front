import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/subject_history.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/presentation/products/top_products_screen/top_products_view_model.dart';
import 'package:web/web.dart' as html;

class TopProductsScreen extends StatelessWidget {
  const TopProductsScreen({super.key});

  // Форматирование цены с разделителем тысяч и символом рубля
  String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} ₽';
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TopProductsViewModel>();
    final isLoading = model.isLoading;
    final subjectName = model.subjectName;
    final topProducts = model.topProducts;
    final subjectsHistory = model.subjectsHistory;

    topProducts.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            subjectName,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.black54,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFF1f1f1f)),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _GraphsSection(subjectsHistory: subjectsHistory),
                  const SizedBox(height: 16),
                  Divider(
                    thickness: 2,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  // Отображаем список топовых продуктов
                  const Text(
                    'Топ товаров',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...topProducts
                      .map((product) => _ProductCard(product: product)),
                ],
              ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Информация'),
          content: const Text(
            'Данные предоставляются за последнюю календарную неделю и учитываются только продажи со склада Wildberries.',
          ),
          actions: [
            TextButton(
              child: const Text('Понятно'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _GraphsSection extends StatelessWidget {
  final List<SubjectHistory> subjectsHistory;

  const _GraphsSection({required this.subjectsHistory});

  @override
  Widget build(BuildContext context) {
    if (subjectsHistory.isEmpty) {
      return const Center(child: Text('Нет данных для отображения графиков.'));
    }

    // Сортируем данные по дате
    final sortedData = List<SubjectHistory>.from(subjectsHistory);
    sortedData.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return dateA.compareTo(dateB);
    });

    // Извлекаем данные для графиков
    final dates = sortedData.map((e) => DateTime.parse(e.date)).toList();
    final revenues = sortedData.map((e) => e.totalRevenue).toList();
    final orders = sortedData.map((e) => e.totalOrders).toList();
    final percentages =
        sortedData.map((e) => e.percentageSkusWithoutOrders).toList();
    final totalSkus = sortedData.map((e) => e.totalSkus).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Графики показателей',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _LineChartWidget(
          title: 'Общая выручка',
          dataPoints: revenues,
          dates: dates,
          yLabelFormatter: (value) => formatYAxisLabel(value),
          lineColor: Colors.blue,
        ),
        const SizedBox(height: 24),
        _LineChartWidget(
          title: 'Общее количество заказов',
          dataPoints: orders,
          dates: dates,
          yLabelFormatter: (value) => value.toStringAsFixed(0),
          lineColor: Colors.green,
        ),
        const SizedBox(height: 24),
        _LineChartWidget(
          title: 'Процент товаров без заказов',
          dataPoints: percentages,
          dates: dates,
          yLabelFormatter: (value) => '${value.toStringAsFixed(0)}%',
          lineColor: Colors.red,
        ),
        const SizedBox(height: 24),
        _LineChartWidget(
          title: 'Количество карточек на первых двух страницах',
          dataPoints: totalSkus,
          dates: dates,
          yLabelFormatter: (value) => value.toStringAsFixed(0),
          lineColor: Colors.purple,
        ),
      ],
    );
  }

  String formatYAxisLabel(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(0)}B';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(0)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class _LineChartWidget extends StatelessWidget {
  final String title;
  final List<int> dataPoints;
  final List<DateTime> dates;
  final String Function(double) yLabelFormatter;
  final Color lineColor;

  const _LineChartWidget({
    required this.title,
    required this.dataPoints,
    required this.dates,
    required this.yLabelFormatter,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty || dates.isEmpty) {
      return const SizedBox.shrink();
    }

    // Подготавливаем данные для графика
    final spots = List.generate(dataPoints.length, (index) {
      return FlSpot(index.toDouble(), dataPoints[index].toDouble());
    });

    // Определяем минимальные и максимальные значения для оси Y
    final minY = dataPoints.reduce(min).toDouble();
    final maxY = dataPoints.reduce(max).toDouble();

    // Рассчитываем линию тренда
    final trendLineSpots = _calculateTrendLine(spots);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (dataPoints.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: lineColor,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: trendLineSpots,
                      isCurved: false,
                      barWidth: 2,
                      color: Colors.grey,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0), // Отступ для лучшего размещения
                            child: Text(
                              yLabelFormatter(value),
                              style: const TextStyle(
                                  fontSize: 10), // Уменьшаем размер шрифта
                            ),
                          );
                        },
                        interval: ((maxY - minY) / 5)
                            .abs(), // Интервал между значениями
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: max(1, (dates.length / 4).floorToDouble()),
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          final date = dates[index];
                          final formattedDate =
                              DateFormat('dd MMM').format(date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(),
                      left: BorderSide(),
                      right: BorderSide(),
                      top: BorderSide(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _calculateTrendLine(List<FlSpot> spots) {
    final n = spots.length;
    if (n < 2) return spots;

    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (var spot in spots) {
      sumX += spot.x;
      sumY += spot.y;
      sumXY += spot.x * spot.y;
      sumX2 += spot.x * spot.x;
    }

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator.abs() < 1e-10) {
      return spots;
    }

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    return spots.map((spot) {
      final y = slope * spot.x + intercept;
      return FlSpot(spot.x, y.roundToDouble());
    }).toList();
  }
}

class _ProductCard extends StatelessWidget {
  final TopProduct product;

  const _ProductCard({required this.product});

  // Форматирование цены с разделителем тысяч и символом рубля
  String formatCurrency(int amountInKopecks) {
    final amount = (amountInKopecks / 100).toStringAsFixed(0);
    return '${amount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} ₽';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          html.window.open(
              'https://www.wildberries.ru/catalog/${product.sku}/detail.aspx',
              'wb');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Изображение продукта
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.img,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Информация о продукте
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название продукта
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Поставщик
                    Text(
                      'Поставщик: ${product.supplier}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Рейтинг и отзывы
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.reviewRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${product.feedbacks} отзывов)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Общие заказы и выручка
                    Text(
                      'Заказов: ${product.totalOrders}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Выручка: ${formatCurrency(product.totalRevenue)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
