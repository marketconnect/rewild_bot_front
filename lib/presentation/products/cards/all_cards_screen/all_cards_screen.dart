import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/color.dart';

import 'package:rewild_bot_front/core/utils/extensions/strings.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/group_model.dart';

import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/widgets/my_sliver_persistent_header_delegate.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/widgets/product_card_widget.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:web/web.dart' as html;

import 'package:js/js.dart';
//
import 'package:shimmer/shimmer.dart';

// external function from index.html
@JS('closeTelegramApp')
external void closeTelegramApp();

class AllCardsScreen extends StatefulWidget {
  const AllCardsScreen({super.key});

  @override
  State<AllCardsScreen> createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();

    final refresh = model.refresh;
    List<CardOfProductModel> productCards = model.productCards;
    final selectedGroup = model.selectedGroup;
    int selectedGroupIndex = 0;
    final groups = model.groups;
    final isLoading = model.isLoading;

    final selectingForPayment = model.selectingForHandle;

    // buy btn
    final isSelectingForPayment = model.selectingForHandle;
    final track = model.track;
    if (selectedGroup != null) {
      final groupsIds = selectedGroup.cardsNmIds;

      productCards = productCards.where((card) {
        return groupsIds.contains(card.nmId);
      }).toList();
      final grName = selectedGroup.name;

      selectedGroupIndex = groups.indexWhere((group) => group.name == grName);
    }

    final selectionInProcess = model.selectionInProcess;
    final emptySubscriptionsQty = model.emptySubscriptionsQty;
    final len = model.selectedLength;
    final headerSliverBuilderItems = selectionInProcess
        ? [
            if (productCards.isNotEmpty)
              _HorizontalScrollMenu(
                  selectedGroupIndex: selectedGroupIndex,
                  cardsNmIds: productCards.map((e) => e.nmId).toList())
          ]
        : [
            const _AppBar(),
            if (!isLoading && productCards.isNotEmpty)
              _HorizontalScrollMenu(
                  selectedGroupIndex: selectedGroupIndex,
                  cardsNmIds: productCards.map((e) => e.nmId).toList()),
          ];

    return SafeArea(
      child: Scaffold(
        floatingActionButton:
            (isSelectingForPayment != null && isSelectingForPayment)
                ? TextButton(
                    onPressed: () {
                      if (emptySubscriptionsQty - len < 0) {
                        Navigator.of(context)
                            .pushNamed(MainNavigationRouteNames.paymentScreen);
                      } else {
                        track();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.width * 0.18,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('Отслеживать',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                : null,
        body: DefaultTabController(
          length: selectionInProcess ? 1 : groups.length,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return headerSliverBuilderItems;
            },
            body: !isLoading &&
                    productCards
                        .isEmpty // Body ============================================================== Body
                ? const _EmptyProductsCards()
                : Stack(children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await refresh();
                      },
                      child: ListView.builder(
                        itemCount: isLoading ? 7 : productCards.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (!isLoading &&
                              (index > (productCards.length - 1))) {
                            return Container();
                          }
                          if ((selectionInProcess) &&
                              index == productCards.length - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 50.0),
                              child: isLoading
                                  ? Shimmer(
                                      gradient: shimmerGradient,
                                      child: _GestureDetectorCard(
                                          isShimmer: true,
                                          productCard:
                                              createFakeCardOfProductModel()),
                                    )
                                  : _GestureDetectorCard(
                                      productCard: productCards[index]),
                            );
                          }
                          return isLoading
                              ? Shimmer(
                                  gradient: shimmerGradient,
                                  child: _GestureDetectorCard(
                                      isShimmer: true,
                                      productCard:
                                          createFakeCardOfProductModel()),
                                )
                              : _GestureDetectorCard(
                                  productCard: productCards[index]);
                        },
                      ),
                    ),
                    if (selectionInProcess &&
                        selectingForPayment != null &&
                        !selectingForPayment)
                      const _BottomMergeBtn()
                  ]),
          ),
        ),
      ),
      // ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  void openBrowserAndCloseApp() {
    // first open browser
    html.window.open('https://www.wildberries.ru/', 'wb');

    // Wait for 5 seconds before closing the app to be sure that the browser window is closed
    Future.delayed(const Duration(seconds: 5), () {
      closeTelegramApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final isLoading = model.isLoading;
    return SliverAppBar(
      // AppBar ========================================================== AppBar
      pinned: false,
      expandedHeight: 60.0,
      collapsedHeight: 60.0,
      actions: [
        if (!isLoading)
          IconButton(
            onPressed: () {
              openBrowserAndCloseApp();
            },
            icon: Image.asset("assets/images/wb.png"),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(0, 15, 35, 15),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              height: 60.0,
              child: const Text(
                'Карточки',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1f1f1f),
                ),
              ),
            ),
          ],
        ),
        stretchModes: const [StretchMode.zoomBackground],
      ),
    );
  }
}

class _BottomMergeBtn extends StatelessWidget {
  const _BottomMergeBtn();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final combineOrDeleteFromGroup = model.combineOrDeleteFromGroup;
    final selectedGroup = model.selectedGroup;
    return Align(
      // Bottom merge btn ============================================================== Bottom merge btn
      alignment: Alignment.bottomRight,
      child: Container(
        width: model.screenWidth * 0.42,
        height: 55,
        margin: const EdgeInsets.only(bottom: 25, right: 25),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                combineOrDeleteFromGroup();
              },
              child: Row(
                children: [
                  Icon(
                    selectedGroup == null
                        ? Icons.group_add_outlined
                        : Icons.group_off_outlined,
                    size: model.screenWidth * 0.06,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: model.screenWidth * 0.02,
                        ),
                        child: Text(
                          selectedGroup == null ? 'В группу' : 'Из группы',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: model.screenWidth * 0.04,
                              color: Theme.of(context).colorScheme.onPrimary),
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

class _GestureDetectorCard extends StatelessWidget {
  const _GestureDetectorCard({
    required this.productCard,
    this.isShimmer = false,
  });

  final CardOfProductModel productCard;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final onCardLongPress = model.onCardLongPress;
    final onCardTap = model.onCardTap;
    final id = productCard.nmId;
    final missingInSubscriptions = model.missingCardIds;
    final isNotPaid = missingInSubscriptions.contains(id);
    final isSelected = model.selectedNmIds.contains(id);
    final selectedGroup = model.selectedGroup;
    final isSelectingForHandle = model.selectingForHandle;
    final grossProfitOrNull = model.grossProfit[id];
    final isUserNmId = model.isUserNmId(id);
    return GestureDetector(
      onTap: () {
        if (isShimmer) {
          return;
        }
        if (isSelectingForHandle != null &&
            isSelectingForHandle &&
            !isNotPaid) {
          return;
        }

        if (isSelectingForHandle != null &&
            !isSelectingForHandle &&
            isNotPaid) {
          return;
        }

        onCardTap(id);
      },
      onLongPress: () {
        if (isShimmer) {
          return;
        }
        // accessible when first card selection is in process
        // or when selecting not for payment
        if (isSelectingForHandle != null &&
            isSelectingForHandle &&
            !isNotPaid) {
          return;
        }
        if (isSelectingForHandle != null &&
            !isSelectingForHandle &&
            isNotPaid) {
          return;
        }

        onCardLongPress(id);
      },
      child: ProductCardWidget(
        productCard: productCard,
        isShimmer: isShimmer,
        userNmId: isUserNmId,
        grossProfit: grossProfitOrNull,
        isNotPaid: isNotPaid,
        inAnyGroup: selectedGroup != null,
        isSelected: isSelected,
      ),
    );
  }
}

class _EmptyProductsCards extends StatelessWidget {
  const _EmptyProductsCards();
  void openBrowserAndCloseApp() {
    // first open browser
    html.window.open('https://www.wildberries.ru/', 'wb');

    // Wait for 5 seconds before closing the app to be sure that the browser window is closed
    Future.delayed(const Duration(seconds: 5), () {
      closeTelegramApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Чтобы добавить карточки товаров, просто поделитесь ссылкой на товар в чат бота.",
              textAlign: TextAlign.center,
            ),
          ),
          CustomElevatedButton(
            onTap: () {
              openBrowserAndCloseApp();
            },
            text: "Добавить",
            buttonStyle: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary)),
            margin: EdgeInsets.fromLTRB(
                model.screenWidth * 0.3,
                model.screenHeight * 0.05,
                model.screenWidth * 0.3,
                model.screenHeight * 0.05),
          ),
        ],
      ),
    );
  }
}

class _HorizontalScrollMenu extends StatefulWidget {
  const _HorizontalScrollMenu(
      {required this.selectedGroupIndex, required this.cardsNmIds});
  final int selectedGroupIndex;
  final List<int> cardsNmIds;
  @override
  State<_HorizontalScrollMenu> createState() => _HorizontalScrollMenuState();
}

class _HorizontalScrollMenuState extends State<_HorizontalScrollMenu>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final onClear = model.onClearSelected;
    final onDelete = model.deleteCards;

    final len = model.selectedLength;
    final selectionInProcess = model.selectionInProcess;
    List<GroupModel> groups = model.groups;

    final isLoading = model.isLoading;
    final selectGroup = model.selectGroup;
    final productsCardsIsEmpty = model.productCards.isEmpty;
    final emptySubscriptionsQty = model.emptySubscriptionsQty;
    _tabController = TabController(
      length: selectionInProcess ? 1 : groups.length,
      vsync: this,
      initialIndex: selectionInProcess ? 0 : widget.selectedGroupIndex,
    );

    return SliverPersistentHeader(
      delegate: MySliverPersistentHeaderDelegate(
        TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          unselectedLabelColor: Theme.of(context).colorScheme.primary,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 7),
          labelColor: selectionInProcess
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          onTap: (index) {
            if (selectionInProcess) {
              return;
            }

            selectGroup(index);
          },
          indicator: selectionInProcess || productsCardsIsEmpty
              ? const BoxDecoration(border: null)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).colorScheme.primary,
                ),
          dividerColor: Colors.transparent,
          tabs: selectionInProcess
              ? [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Tab(
                            child: IconButton(
                              icon: Icon(Icons.close,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: model.screenWidth * 0.08),
                              onPressed: () => onClear(),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          emptySubscriptionsQty - len > 0
                              ? Text(
                                  '$len/${emptySubscriptionsQty - len}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.update,
                                ),
                        ],
                      ),
                      SizedBox(
                        width: model.screenWidth * 0.3,
                      ),
                      // if (!someUserNmIdIsSelected)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () =>
                                  _openAnimatedDialog(context, len, onDelete),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: model.screenWidth * 0.08,
                              )),
                        ],
                      ),
                    ],
                  ),
                ]
              : groups
                  .map(
                    (group) => Tab(
                      child: GestureDetector(
                        onLongPress: () {
                          _showGroupOptionsDialog(group, model);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isLoading || productsCardsIsEmpty
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            width: model.screenWidth * 0.25,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                group.name.capitalize().take(5),
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
      pinned: true,
    );
  }

  // Внутри _HorizontalScrollMenuState
  void _showGroupOptionsDialog(
      GroupModel group, AllCardsScreenViewModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Опции для группы "${group.name}"'),
          content: const Text('Выберите действие:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRenameGroupDialog(group, model);
              },
              child: const Text('Переименовать'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteGroup(group, model);
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameGroupDialog(GroupModel group, AllCardsScreenViewModel model) {
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _controller =
        TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Переименовать группу'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Новое название группы',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final newGroupName = _controller.text.trim();
                if (newGroupName.isNotEmpty) {
                  model.renameGroup(group.name, newGroupName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _openAnimatedDialog(
      BuildContext context, int cardsLength, Future<void> Function() onDelete) {
    final cardsName =
        cardsLength == 1 || (cardsLength != 11 && cardsLength % 10 == 1)
            ? "карточку"
            : cardsLength > 4 && cardsLength < 21
                ? "карточек"
                : "карточки";

    final text = "Удалить $cardsLength $cardsName?";
    _showGeneralDialog(context, text, onDelete);
  }

  void _confirmDeleteGroup(GroupModel group, AllCardsScreenViewModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить группу'),
          content:
              Text('Вы уверены, что хотите удалить группу "${group.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                // Удаляем группу через ViewModel
                // final model = context.read<AllCardsScreenViewModel>();
                model.deleteGroup(group.name);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Object?> _showGeneralDialog(
      BuildContext context, String text, Future<void> Function() onDelete) {
    return showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Container();
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return AlertDialog(
              insetPadding: const EdgeInsets.all(10),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              buttonPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              title:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.warning_amber,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: Theme.of(context).colorScheme.error),
              ]),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          )),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      )),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onDelete();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.errorContainer,
                          )),
                      child: Text(
                        'Удалить',
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                      )),
                ),
              ]);
        });
  }
}

CardOfProductModel createFakeCardOfProductModel() {
  return CardOfProductModel(
    nmId: 1,
    name: "■■■■■■■■■■■■■■■■■■■■",
    img:
        "https://basket-02.wbbasket.ru/vol160/part16020/16020241/images/big/1.webp",
    sellerId: 123,
    tradeMark: "Sample TradeMark",
    subjectId: 456,
    subjectParentId: 789,
    brand: "Sample Brand",
    supplierId: 101,
    basicPriceU: 1000,
    pics: 2,
    rating: 4,
    reviewRating: 4.5,
    feedbacks: 20,
    promoTextCard: "Special Offer",
    createdAt: DateTime.now().millisecondsSinceEpoch,
    my: 0,
    sizes: [/* Add SizeModel instances here */],
    initialStocks: [/* Add InitialStockModel instances here */],
  );
}
