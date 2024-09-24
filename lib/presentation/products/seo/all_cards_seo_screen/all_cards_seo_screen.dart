import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_view_model.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class AllCardsSeoScreen extends StatelessWidget {
  const AllCardsSeoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsSeoViewModel>();
    final isLoading = model.isLoading;
    final goToSeoToolScreen = model.goToSeoToolScreen;
    final getCardContent = model.getCardContent;
    final products = model.cards;
    final apikeyExists = model.apiKeyExists;

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ваши товары'),
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: apikeyExists || isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final cardContent = getCardContent(product.nmId);
                  return GestureDetector(
                    onTap: () {
                      if (cardContent == null) return;
                      goToSeoToolScreen(product: product, card: cardContent);
                    },
                    child: ProductCard(productCard: product),
                  );
                },
              )
            : ApiKeyMissingWidget(
                onAddApiKeyPressed: () => model.onAddApiKeyPressed(),
                onSeoByCategoryPressed: () => model.onSeoByCategoryPressed(),
              ),
        floatingActionButton: apikeyExists
            ? FloatingActionButton(
                onPressed: () {
                  model.onSeoByCategoryPressed();
                },
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.category),
              )
            : null,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final CardOfProductModel productCard;

  const ProductCard({
    required this.productCard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ReWildNetworkImage(
                  width: 100, height: 100, image: productCard.img),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productCard.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Категория: ${productCard.name}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        productCard.rating.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
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

class ApiKeyMissingWidget extends StatelessWidget {
  final VoidCallback onAddApiKeyPressed;
  final VoidCallback onSeoByCategoryPressed;

  const ApiKeyMissingWidget({
    super.key,
    required this.onAddApiKeyPressed,
    required this.onSeoByCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'API ключ не добавлен',
            textAlign: TextAlign.center,
            // style: Theme.of(context).textTheme.titleLarge.copyWith(
            //       color: Theme.of(context).primaryColor,
            //       fontWeight: FontWeight.bold,
            //     ),
          ),
          const SizedBox(height: 8),
          Text(
            'Для подключения к API портала продавца, добавьте API токен или воспользуйтесь генерацией SEO без API.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddApiKeyPressed,
            icon: const Icon(Icons.vpn_key),
            label: const Text('Добавить API токен'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onSeoByCategoryPressed,
            icon: const Icon(Icons.category),
            label: const Text('SEO по категориям'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
