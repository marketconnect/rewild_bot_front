import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
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
    final onCardTap = model.selectCard;
    final clearSelection = model.clearSelection;
    final selectedCards = model.selectedCards;
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
              if (selectedCards.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: clearSelection,
                ),
            ],
            scrolledUnderElevation: 2,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.transparent),
        floatingActionButton: selectedCards.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  goBack();
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                label: Text('Добавить (${selectedCards.length})',
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
            : ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final isSelected = selectedCards.contains(card);
                  return GestureDetector(
                    onTap: () => onCardTap(card),
                    child: Container(
                      margin: cards.length == index + 1
                          ? const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 60.0)
                          : const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ReWildNetworkImage(
                            width: screenWidth * 0.2,
                            image: card.img,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              card.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
