import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/user_product_card.dart';
import 'package:rewild_bot_front/presentation/home/unit_economics_all_cards_screen/unit_economics_all_cards_view_model.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';

class UnitEconomicsAllCardsScreen extends StatelessWidget {
  const UnitEconomicsAllCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UnitEconomicsAllCardsViewModel>();
    final isLoading = model.isLoading;
    final userProductCards = model.userProductCards;
    final isApiKeyExists = model.apiKeyExists;

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Все карточки'),
          centerTitle: true,
        ),
        body: isApiKeyExists
            ? ListView.builder(
                itemCount: userProductCards.length,
                itemBuilder: (context, index) {
                  final product = userProductCards[index];
                  return _buildProductCard(context, product);
                },
              )
            : const _EmptyApiKeyWidget(),
      ),
    );
  }

  // Method to build each product card
  Widget _buildProductCard(BuildContext context, UserProductCard product) {
    Color cardColor = Colors.white;
    Widget unitEconomicsWidget;
    final model = context.watch<UnitEconomicsAllCardsViewModel>();
    final openExpenseManager = model.expenseManagerScreen;
    if (product.totalCost == null || product.totalCost == 0) {
      // Highlight cards with missing unit economics
      cardColor = Colors.yellow.shade50;
      unitEconomicsWidget = const Text(
        'Нет данных о затратах',
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      unitEconomicsWidget = Text(
        'Прибыль на единицу: ${product.totalCost!.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Card(
      color: cardColor,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          openExpenseManager(product.sku);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.img,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // SKU and Marketplace
                    Text(
                      'SKU: ${product.sku} • ${product.mp}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Все затраты
                    unitEconomicsWidget,
                  ],
                ),
              ),
              // Optional: Icon indicating status
              if (product.totalCost == null)
                const Icon(Icons.info_outline, color: Colors.orange),
              if (product.totalCost != null && product.totalCost! < 0)
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyApiKeyWidget extends StatelessWidget {
  const _EmptyApiKeyWidget();

  @override
  Widget build(BuildContext context) {
    final addToken = context.read<UnitEconomicsAllCardsViewModel>().addToken;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EmptyWidget(
            text:
                'Для работы с этим разделом вам необходимо добавить токен "Контент"'),
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
