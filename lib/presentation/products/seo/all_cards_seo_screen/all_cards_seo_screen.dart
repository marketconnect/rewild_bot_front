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
            surfaceTintColor: Colors.transparent),
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
                    child: ProductCard(
                      productCard: product,
                    ),
                  );
                },
              )
            : ApiKeyMissingWidget(
                onAddApiKeyPressed: () => model.onAddApiKeyPressed(),
                onSeoByCategoryPressed: () => model.onSeoByCategoryPressed(),
              ),
        bottomNavigationBar: apikeyExists
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    model.onSeoByCategoryPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Без товара'),
                ),
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
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  const SizedBox(height: 8),
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
    Key? key,
    required this.onAddApiKeyPressed,
    required this.onSeoByCategoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Замените иконку на иллюстрацию, если есть
                Icon(
                  Icons.vpn_key_off,
                  color: theme.primaryColor,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'API ключ не добавлен',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Чтобы воспользоваться всеми возможностями приложения, пожалуйста, добавьте API токен.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onAddApiKeyPressed,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить API токен'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onSeoByCategoryPressed,
                  icon: const Icon(Icons.category),
                  label: const Text('Продолжить без API'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
