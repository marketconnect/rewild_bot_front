import 'package:flutter/material.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';

List<TopProduct> topProducts = [
  TopProduct(
    sku: 100001,
    totalOrders: 1200,
    totalRevenue: 300000,
    subjectId: 1,
    name: "Wireless Bluetooth Headphones",
    supplier: "TechGear",
    reviewRating: 4.8,
    feedbacks: 320,
    img: "https://example.com/images/headphones.jpg",
  ),
  TopProduct(
    sku: 100002,
    totalOrders: 980,
    totalRevenue: 245000,
    subjectId: 1,
    name: "Smartphone XYZ",
    supplier: "MobilePlus",
    reviewRating: 4.7,
    feedbacks: 290,
    img: "https://example.com/images/smartphone.jpg",
  ),
  TopProduct(
    sku: 100003,
    totalOrders: 760,
    totalRevenue: 190000,
    subjectId: 2,
    name: "Laptop Pro 15",
    supplier: "Computech",
    reviewRating: 4.5,
    feedbacks: 210,
    img: "https://example.com/images/laptop.jpg",
  ),
  TopProduct(
    sku: 100004,
    totalOrders: 1500,
    totalRevenue: 375000,
    subjectId: 2,
    name: "Gaming Monitor 4K",
    supplier: "DisplayTech",
    reviewRating: 4.9,
    feedbacks: 400,
    img: "https://example.com/images/monitor.jpg",
  ),
  TopProduct(
    sku: 100005,
    totalOrders: 520,
    totalRevenue: 130000,
    subjectId: 3,
    name: "Smart Watch GT",
    supplier: "Wearable World",
    reviewRating: 4.6,
    feedbacks: 180,
    img: "https://example.com/images/smartwatch.jpg",
  ),
  TopProduct(
    sku: 100006,
    totalOrders: 860,
    totalRevenue: 215000,
    subjectId: 3,
    name: "Fitness Tracker",
    supplier: "HealthTech",
    reviewRating: 4.3,
    feedbacks: 250,
    img: "https://example.com/images/fitnesstracker.jpg",
  ),
  TopProduct(
    sku: 100007,
    totalOrders: 1100,
    totalRevenue: 275000,
    subjectId: 4,
    name: "Action Camera Pro",
    supplier: "AdventureGear",
    reviewRating: 4.8,
    feedbacks: 300,
    img: "https://example.com/images/actioncamera.jpg",
  ),
  TopProduct(
    sku: 100008,
    totalOrders: 650,
    totalRevenue: 162500,
    subjectId: 4,
    name: "Drone Quadcopter",
    supplier: "FlyTech",
    reviewRating: 4.7,
    feedbacks: 240,
    img: "https://example.com/images/drone.jpg",
  ),
  TopProduct(
    sku: 100009,
    totalOrders: 1400,
    totalRevenue: 350000,
    subjectId: 5,
    name: "4K Smart TV",
    supplier: "ScreenMasters",
    reviewRating: 4.9,
    feedbacks: 380,
    img: "https://example.com/images/smarttv.jpg",
  ),
  TopProduct(
    sku: 100010,
    totalOrders: 900,
    totalRevenue: 225000,
    subjectId: 5,
    name: "Home Theater System",
    supplier: "SoundWave",
    reviewRating: 4.6,
    feedbacks: 270,
    img: "https://example.com/images/hometheater.jpg",
  ),
];

class TopProductsScreen extends StatelessWidget {
  const TopProductsScreen({super.key});

  // Форматирование цены с разделителем тысяч и символом рубля
  String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₽';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Топ продуктов'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: topProducts.length,
        itemBuilder: (context, index) {
          final product = topProducts[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final TopProduct product;

  const _ProductCard({required this.product});

  // Форматирование цены с разделителем тысяч и символом рубля
  String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₽';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Действие при нажатии на карточку (если необходимо)
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
