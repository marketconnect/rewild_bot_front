import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_products_questions_screen/all_products_questions_view_model.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';
import 'package:rewild_bot_front/widgets/popum_menu_item.dart';

class AllProductsQuestionsScreen extends StatefulWidget {
  const AllProductsQuestionsScreen({super.key});

  @override
  State<AllProductsQuestionsScreen> createState() =>
      _AllProductsQuestionsScreenState();
}

class _AllProductsQuestionsScreenState
    extends State<AllProductsQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllProductsQuestionsViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final apiKeyexists = model.apiKeyExists;

    final isQuestionsLoading = model.isQuestionsLoading;

    final questionsQty = model.questionsQty;
    final onClose = model.onClose;

    final itemsIdsList = model.questions;

    final getImages = model.getImage;
    final getNewQuestionsQty = model.unansweredQuestionsQty;

    final getallQuestionsQty = model.allQuestionsQty;

    final getSupplierArticle = model.getSupplierArticle;
    final goTo = model.goTo;

    final isClosing = model.isClosing;

    // filter by period
    final setPeriod = model.setPeriod;
    final period = model.period;
    return SizedBox(
        width: double.infinity,
        // the most important part of this example
        child: OverlayLoaderWithAppIcon(
          isLoading: isClosing || isQuestionsLoading,
          overlayBackgroundColor: Colors.black,
          circularProgressColor: const Color(0xff83735c),
          appIcon: Image.asset(ImageConstant.imgLogoForLoading),
          child: Scaffold(
            appBar: _AppBar(
                onClose: onClose,
                apiKeyexists: apiKeyexists,
                setPeriod: setPeriod,
                period: period),
            body: !apiKeyexists
                ? const EmptyWidget(
                    text: 'Создайте API ключ, чтобы видеть вопросы',
                  )
                : (itemsIdsList.isEmpty)
                    ? EmptyWidget(
                        text:
                            'Нет вопросов${period == 'w' ? ' за последнюю неделю' : period == 'm' ? ' за последний месяц' : ''}')
                    : SingleChildScrollView(
                        child: Column(children: [
                          Column(
                            children: itemsIdsList.toList().map((e) {
                              return _ProductCard(
                                nmId: e,
                                image: getImages(e),
                                goTo: goTo,
                                newItemsQty: getNewQuestionsQty(e),
                                supplierArticle: getSupplierArticle(e),
                                difCurrentPrevUnansweredQty:
                                    model.difQuestion(e),
                                oldItemsQty: getallQuestionsQty(e),
                              );
                            }).toList(),
                          )
                        ]),
                      ),
          ),
        ));
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.onClose,
    required this.apiKeyexists,
    required this.setPeriod,
    required this.period,
  });

  final Future<void> Function() onClose;
  final bool apiKeyexists;
  final Future<void> Function(BuildContext context, String value) setPeriod;
  final String period;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          await onClose();
        },
      ),
      centerTitle: true,
      title: const Text("Вопросы"),
      actions: [
        if (apiKeyexists)
          PopupMenuButton(
            // Menu ============================================ Menu
            onSelected: (value) => setPeriod(context, value),
            icon: Icon(
              Icons.menu,
              size: MediaQuery.of(context).size.width * 0.1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'w',
                  child: ReWildPopumMenuItemChild(
                    text: "За неделю",
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: period == 'w' ? const Icon(Icons.check) : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'm',
                  child: ReWildPopumMenuItemChild(
                    text: "За месяц",
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: period == 'm' ? const Icon(Icons.check) : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'a',
                  child: ReWildPopumMenuItemChild(
                    text: "За все время",
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: period == 'a' ? const Icon(Icons.check) : null,
                    ),
                  ),
                )
              ];
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.image,
    required this.newItemsQty,
    required this.nmId,
    required this.oldItemsQty,
    required this.goTo,
    required this.supplierArticle,
    required this.difCurrentPrevUnansweredQty,
  });
  final int nmId;
  final String image;
  final String supplierArticle;
  final int newItemsQty;
  final int difCurrentPrevUnansweredQty;
  final int oldItemsQty;

  final Function(int nmId) goTo;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => goTo(nmId),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.1),
            ),
          ),
          // borderRadius: BorderRadius.circular(10),
        ),
        child: AspectRatio(
          aspectRatio: 10 / 3,
          child: SizedBox(
            width: screenWidth,
            child: Stack(
              children: [
                Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: (image.isEmpty)
                          ? Image.asset(ImageConstant.empty,
                              fit: BoxFit.scaleDown)
                          : ReWildNetworkImage(
                              width: screenWidth * 0.33, image: image),
                    ),
                    SizedBox(
                      width: screenWidth * 0.05,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: Text(
                            supplierArticle,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Всего вопросов: $oldItemsQty',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Без ответа: $newItemsQty',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.7),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                if (difCurrentPrevUnansweredQty != 0)
                  Positioned(
                      right: 5,
                      bottom: 5,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            '$difCurrentPrevUnansweredQty',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
