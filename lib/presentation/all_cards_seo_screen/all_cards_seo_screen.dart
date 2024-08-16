import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/presentation/all_cards_seo_screen/all_cards_seo_view_model.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class AllCardsSeoScreen extends StatelessWidget {
  const AllCardsSeoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsSeoViewModel>();
    final isLoading = model.isLoading;
    final goToSeoToolScreen = model.goToSeoToolScreen;
    final getCardContent = model.getCardContent;
    final products = model.cards;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Ваши товары'),
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent),
      body: isLoading
          ? const Center(child: MyProgressIndicator())
          : ListView.builder(
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
                  width: 100, height: 100, image: productCard.img ?? ""),
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
                  // Row(
                  //   children: [
                  //     const Icon(
                  //       Icons.star,
                  //       color: Colors.amber,
                  //       size: 20,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       productCard.rating.toString(),
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: Theme.of(context).colorScheme.onSurface,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
