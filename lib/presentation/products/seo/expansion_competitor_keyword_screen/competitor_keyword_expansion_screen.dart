import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_competitor_keyword_screen/competitor_keyword_expansion_model.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class CompetitorKeywordExpansionScreen extends StatefulWidget {
  const CompetitorKeywordExpansionScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CompetitorKeywordExpansionScreenState createState() =>
      _CompetitorKeywordExpansionScreenState();
}

class _CompetitorKeywordExpansionScreenState
    extends State<CompetitorKeywordExpansionScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<CompetitorKeywordExpansionViewModel>();
    final isLoading = model.isLoading;
    final cards = model.cards;
    final topProducts = model.topProducts;

    final onCardTap = model.selectCard;
    final onTopProductTap = model.selectTopProduct;

    final clearSelection = model.clearSelection;

    final selectedCards = model.selectedCards;
    final selectedTopProducts = model.selectedTopProducts;

    final totalSelectedCount =
        selectedCards.length + selectedTopProducts.length;

    final goBack = model.goBack;
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Карточки'),
          actions: [
            if (totalSelectedCount > 0)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: clearSelection,
              ),
          ],
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),

        // В методе build
        floatingActionButton: totalSelectedCount > 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  goBack();
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                label: Text('Добавить ($totalSelectedCount)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary)),
                icon: Icon(Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary),
              )
            : null,

        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: cards.isEmpty
            ? const Center(
                child: Text('Вы не отслеживаете ни одного конкурента.'))
            : _buildBody(
                context,
                screenWidth,
                topProducts,
                cards,
                selectedCards,
                selectedTopProducts,
                onCardTap,
                onTopProductTap,
                totalSelectedCount),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double screenWidth,
    List<TopProduct> topProducts,
    List<CardOfProductModel> cards,
    Set<CardOfProductModel> selectedCards,
    Set<TopProduct> selectedTopProducts,
    Function(CardOfProductModel) onCardTap,
    Function(TopProduct) onTopProductTap,
    int totalSelectedCount,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        if (topProducts.isNotEmpty) ...[
          _buildTopProducts(context, screenWidth, topProducts,
              selectedTopProducts, onTopProductTap),
          const SizedBox(height: 16.0),
          const Divider(),
        ],
        if (cards.isNotEmpty) ...[
          _buildCardsList(
              context, screenWidth, cards, selectedCards, onCardTap),
        ] else
          const Center(
            child: Text('Вы не отслеживаете ни одного конкурента.'),
          ),
        SizedBox(height: totalSelectedCount > 0 ? 80.0 : 0.0),
      ],
    );
  }

  Widget _buildTopProducts(
    BuildContext context,
    double screenWidth,
    List<TopProduct> topProducts,
    Set<TopProduct> selectedTopProducts,
    Function(TopProduct) onTopProductTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок для topProducts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Топ продукты',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        // Список topProducts
        ListView.builder(
          itemCount: topProducts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final product = topProducts[index];
            final isSelected = selectedTopProducts.contains(product);
            return GestureDetector(
              onTap: () => onTopProductTap(product),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Изображение продукта
                    ReWildNetworkImage(
                      width: screenWidth * 0.2,
                      image: product.img,
                    ),
                    const SizedBox(width: 16),
                    // Название продукта
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardsList(
    BuildContext context,
    double screenWidth,
    List<CardOfProductModel> cards,
    Set<CardOfProductModel> selectedCards,
    Function(CardOfProductModel) onCardTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок для cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Карточки',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        // Список cards
        ListView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final card = cards[index];
            final isSelected = selectedCards.contains(card);
            return GestureDetector(
              onTap: () => onCardTap(card),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Изображение карточки
                    ReWildNetworkImage(
                      width: screenWidth * 0.2,
                      image: card.img,
                    ),
                    const SizedBox(width: 16),
                    // Название карточки
                    Expanded(
                      child: Text(
                        card.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
