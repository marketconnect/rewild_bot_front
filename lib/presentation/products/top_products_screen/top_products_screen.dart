import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/presentation/products/top_products_screen/top_products_view_model.dart';
import 'package:web/web.dart' as html;

class TopProductsScreen extends StatelessWidget {
  const TopProductsScreen({super.key});

  // Форматирование цены с разделителем тысяч и символом рубля
  String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₽';
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TopProductsViewModel>();
    final isLoading = model.isLoading;
    final topProducts = model.topProducts;
    topProducts.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Топ продуктов'),
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
            ]),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: topProducts.length,
          itemBuilder: (context, index) {
            final product = topProducts[index];
            return _ProductCard(product: product);
          },
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

class _ProductCard extends StatelessWidget {
  final TopProduct product;

  const _ProductCard({required this.product});

  // Форматирование цены с разделителем тысяч и символом рубля
  String formatCurrency(int amountInKopecks) {
    final amount = (amountInKopecks / 100).toStringAsFixed(0);
    return '${amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₽';
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
