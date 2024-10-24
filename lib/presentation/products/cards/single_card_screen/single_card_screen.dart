import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rewild_bot_front/core/color.dart';
import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
// import 'package:rewild_bot_front/env.dart';

import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

import 'package:shimmer/shimmer.dart';
import 'package:web/web.dart' as html;

class SingleCardScreen extends StatelessWidget {
  const SingleCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final isNull = model.isNull;
    final openNotifications = model.notificationsScreen;

    final tracked = model.tracked;
    final isLoading = model.isLoading;

    return Scaffold(
      appBar: AppBar(
          actions: [
            if (!isLoading)
              IconButton(
                  onPressed: () => openNotifications(),
                  icon: Icon(
                    tracked
                        ? Icons.notifications_active
                        : Icons.notification_add_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ))
          ],
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent),
      body: isNull ? const _Shimmer() : const _Body(),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Shimmer(
      gradient: shimmerGradient,
      child: Column(
        children: [
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height * 0.65,
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.04,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.04,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.04,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.035,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.black,
                )),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.035,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.black,
                )),
          )
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();

    final listTilesNames = model.listTilesNames;
    final promo = model.promo;
    return SizedBox(
      width: model.screenWidth,
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(children: [
          const _MainPicture(),
          Column(
            children: [
              SizedBox(
                height: model.screenHeight * 0.02,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: model.screenWidth * 0.05),
                child: const _TopProductsLink(),
              ),
              SizedBox(
                height: model.screenHeight * 0.02,
              ),
              SizedBox(
                height: model.screenHeight * 0.02,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: model.screenWidth * 0.05),
                child: const _Feedback(),
              ),
              if (promo.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: model.screenWidth * 0.05,
                      vertical: model.screenHeight * 0.01),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(model.screenWidth * 0.01),
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer),
                      padding: EdgeInsets.symmetric(
                          horizontal: model.screenWidth * 0.02,
                          vertical: model.screenHeight * 0.01),
                      child: Text(promo,
                          style: TextStyle(
                              fontSize: model.screenWidth * 0.04,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer)),
                    ),
                  ]),
                ),
              SizedBox(
                height: model.screenHeight * 0.02,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: model.screenWidth * 0.05),
                child: const _Name(),
              ),
              SizedBox(
                height: model.screenHeight * 0.02,
              ),
              Divider(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ListView.builder(
                  itemCount: listTilesNames.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return _ExpansionTile(
                      index: index,
                    );
                  }),
              const _UnitEconomy(),
            ],
          ),
        ]),
      ),
    );
  }
}

class _UnitEconomy extends StatelessWidget {
  const _UnitEconomy();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final openExpenseManager = model.expenseManagercreen;
    return Column(
      children: [
        CustomElevatedButton(
          onTap: () => openExpenseManager(),
          text: "Юнит-экономика",
          buttonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary,
              ),
              foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary)),
          height: model.screenWidth * 0.2,
          margin: EdgeInsets.fromLTRB(
              model.screenWidth * 0.1,
              model.screenHeight * 0.1,
              model.screenWidth * 0.1,
              model.screenHeight * 0.1),
        ),
      ],
    );
  }
}

class _ExpansionTile extends StatefulWidget {
  const _ExpansionTile({
    required this.index,
  });

  final int index;

  @override
  State<_ExpansionTile> createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<_ExpansionTile> {
  final TextEditingController _searchController = TextEditingController();
  List<KwByLemma> _filteredKeywords = [];

  @override
  void initState() {
    super.initState();
    final model = context.read<SingleCardScreenViewModel>();
    _filteredKeywords = List<KwByLemma>.from(model.keywords);
    _filteredKeywords.sort((a, b) => b.freq.compareTo(a.freq));
    _searchController.addListener(() {
      setState(() {
        _filteredKeywords = model.keywords
            .where((kw) => kw.keyword
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool isToday(int? millisecondsSinceEpoch) {
    if (millisecondsSinceEpoch == null) {
      return false;
    }
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    DateTime now = DateTime.now();

    // Убедитесь, что сравниваемые даты имеют одинаковый год, месяц и день.
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final getTitle = model.getTitle;
    List<Widget> children = _getContent(model, context);

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest))),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedTextColor: Theme.of(context).colorScheme.onSurface,
          textColor: Theme.of(context).colorScheme.onSurface,
          collapsedIconColor: Theme.of(context).colorScheme.onSurface,
          iconColor: Theme.of(context).colorScheme.onSurface,
          title: Text(
            getTitle(widget.index),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: model.screenWidth * 0.05,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          children: [
            ...children,
            SizedBox(
              height: model.screenHeight * 0.05,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _getContent(
      SingleCardScreenViewModel model, BuildContext context) {
    List<Widget> children = [];
    if (widget.index == 0) {
      // Общая информация
      List<_InfoRowContent> widgetsContent = [];
      final sellerName = model.sellerName;

      final brand = model.brand;
      final tradeMark = model.tradeMark;
      final price = model.price;

      final region = model.region;

      widgetsContent.addAll([
        _InfoRowContent(header: "Продавец", text: sellerName),
        _InfoRowContent(header: "Регион регистрации", text: region),
        _InfoRowContent(header: "Брэнд", text: brand),
        _InfoRowContent(header: "Торг. марка", text: tradeMark),
        _InfoRowContent(
            header: "Цена", text: '${(price / 100).toStringAsFixed(0)}₽'),
      ]);

      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();
    } else if (widget.index == 1) {
      // Карточка
      final category = model.category;
      final subject = model.subjectName;
      final commision = model.commission;
      final isHighBuyout = model.isHighBuyout;
      final navigateToAllSubjectsScreen = model.navigateToAllSubjectsScreen;
      List<_InfoRowContent> widgetsContent = [];
      widgetsContent.addAll([
        _InfoRowContent(
            header: "Категория",
            text: category,
            isClickable: true,
            onTap: () {
              navigateToAllSubjectsScreen();
            }),
        _InfoRowContent(header: "Предмет", text: subject)
      ]);
      if (commision != null) {
        widgetsContent.add(_InfoRowContent(
            header: "Комиссия WB", text: '${commision.toString()}%'));
      }
      // if (ordersSum != null) {
      //   widgetsContent.add(_InfoRowContent(
      //       header: "Всего заказов", text: "более $ordersSum шт."));
      // }

      if (isHighBuyout) {
        if (widgetsContent.length % 2 == 0) {
          widgetsContent.insert(
              widgetsContent.length - 1,
              _InfoRowContent(
                  header: "Высокий % выкупов",
                  text: "",
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.check_circle_outline_outlined,
                        size: 30,
                        color: Colors.greenAccent,
                      ),
                    ],
                  )));
        } else {
          widgetsContent.add(_InfoRowContent(
              header: "Высокий % выкупов",
              text: "",
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.check_circle_outline_outlined,
                    size: 30,
                    color: Colors.greenAccent,
                  ),
                ],
              )));
        }
      }

      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();
    } else if (widget.index == 2) {
      final tariffs = model.tariffs;
      final volume = model.volume;
      final setmaxLogistic = model.setMaxLogistic;
      // final logisticsCoef = model.logisticsCoef;

      if (volume == null) {
        return children;
      }

      final List<_InfoRowContent> rowsContents = [];
      rowsContents.add(
        _InfoRowContent(
          header: "Объем, л",
          text: (volume / 10).toStringAsFixed(1),
        ),
      );
      tariffs.forEach((k, v) {
        if (k.isEmpty) {
          return;
        }

        final boxesCoefs = v.where((element) => element.isBoxes());
        final monoPaletsCoefs = v.where((element) => element.isMono());

        double? boxesTariff = 0;
        double? monoPaletsTariff = 0;

        boxesTariff = boxesCoefs.isNotEmpty
            ? (boxesCoefs.first.deliveryBase) +
                (((volume / 10) - 1) * boxesCoefs.first.deliveryLiter)
            : null;
        setmaxLogistic(boxesTariff ?? 0);
        monoPaletsTariff = monoPaletsCoefs.isNotEmpty
            ? (monoPaletsCoefs.first.deliveryBase) +
                (((volume / 10) - 1) * monoPaletsCoefs.first.deliveryLiter)
            : null;
        setmaxLogistic(monoPaletsTariff ?? 0);
        if (boxesTariff == null && monoPaletsTariff == null) {
          return;
        }
        rowsContents.add(
          _InfoRowContent(
            header: k,
            text:
                'Кор: ${boxesTariff != null ? boxesTariff.ceil() : 'Неизвестно'} р.\nМоно: ${monoPaletsTariff != null ? '${monoPaletsTariff.ceil()} р.' : '       -  '}',
          ),
        );
      });
      children = rowsContents
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: rowsContents.indexOf(e) % 2 != 0,
              ))
          .toList();
    } else if (widget.index == 3) {
      // Остатки
      final wareHouses = model.warehouses;
      // final supplies = model.supplies;

      if (wareHouses.length > 1) {
        int stocksSum = 0;

        for (var entry in wareHouses.entries) {
          if (entry.key.isNotEmpty && entry.value > 0) {
            stocksSum += entry.value;
          }
        }
        wareHouses['Все склады'] = stocksSum;
      }
      final List<_InfoRowContent> rowsContents = [];

      wareHouses.forEach((k, v) {
        if (k.isEmpty) {
          return;
        }
        rowsContents.add(
          _InfoRowContent(
            header: k,
            text: '$v шт.',
            // supplies[k] != null && supplies[k]! > 0
            //     ? '(+${supplies[k]!}) $v шт.'
            //     : '$v шт.',
          ),
        );
      });
      children = rowsContents
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: rowsContents.indexOf(e) % 2 != 0,
              ))
          .toList();
    }
    if (widget.index == 4 && model.orders.isNotEmpty) {
      // final todayDate = formateDate(DateTime.now());

      final orders = model.orders;

      final justTodayAddedCard = isToday(model.createdAt);

      if (orders.length > 1) {
        int ordersSum = 0;

        for (var entry in orders.entries) {
          if (entry.key.isNotEmpty && entry.value > 0) {
            ordersSum += entry.value;
          }
        }

        orders['Все склады'] = ordersSum;
        // model.initStocksSum + model.supplySum - model.stocksSum;
      }
      List<_InfoRowContent> widgetsContent = [];

      orders.forEach((whName, sales) {
        if (whName.isEmpty) {
          return;
        }
        widgetsContent.add(
          _InfoRowContent(
              header: whName,
              text: sales > 0
                  ? '$sales шт.'
                  : sales == 0 || justTodayAddedCard
                      ? '-'
                      : sales < -NumericConstants.supplyThreshold
                          ? 'поставка ${-sales} шт.'
                          : 'возврат ${-sales} шт.'),
        );
      });

      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();
      // children.add(
      //   _InfoRowTile(
      //       content: _InfoRowContent(header: '', text: ''),
      //       text: 'За $todayDate',
      //       parentContext: context),
      // );
    }
    if (widget.index == 5 && model.weekOrdersHistoryFromServer.isNotEmpty) {
      final weekOrders = model.weekOrdersHistoryFromServer;
      final justTodayAddedCard = isToday(model.createdAt);
      final weekPeriod = getWeekFromOrderNumber(model.weekNum);
      // final month = getMonthFromOrderNumber(model.monthNum);
      // final from = formateDate(model.from);

      // final to = formateDate(model.to);
      if (weekOrders.length > 1) {
        int ordersSum = 0;

        for (var entry in weekOrders.entries) {
          if (entry.key.isNotEmpty &&
              entry.value > 0 &&
              entry.key != 'Все склады') {
            ordersSum += entry.value;
          }
        }

        weekOrders['Все склады'] = ordersSum;
        // model.initStocksSum + model.supplySum - model.stocksSum;
      }
      List<_InfoRowContent> widgetsContent = [];

      weekOrders.forEach((whName, sales) {
        if (whName.isEmpty) {
          return;
        }
        widgetsContent.add(
          _InfoRowContent(
              header: whName,
              text: sales > 0
                  ? '$sales шт.'
                  : sales == 0 || justTodayAddedCard
                      ? '-'
                      : sales < -NumericConstants.supplyThreshold
                          ? 'поставка ${-sales} шт.'
                          : 'возврат ${-sales} шт.'),
        );
      });
      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();

      children.add(
        _InfoRowTile(
            content: _InfoRowContent(header: '', text: ''),
            text: 'За $weekPeriod',
            parentContext: context),
      );
    }
    if (widget.index == 6 && model.monthOrdersHistoryFromServer.isNotEmpty) {
      final monthOrders = model.monthOrdersHistoryFromServer;
      final justTodayAddedCard = isToday(model.createdAt);
      //  final weekPeriod = getWeekFromOrderNumber(model.weekNum);
      final month = getMonthFromOrderNumber(model.monthNum);

      // final to = formateDate(prevMonth);
      if (monthOrders.length > 1) {
        int ordersSum = 0;

        for (var entry in monthOrders.entries) {
          if (entry.key.isNotEmpty &&
              entry.value > 0 &&
              entry.key != 'Все склады') {
            ordersSum += entry.value;
          }
        }

        monthOrders['Все склады'] = ordersSum;
        // model.initStocksSum + model.supplySum - model.stocksSum;
      }
      List<_InfoRowContent> widgetsContent = [];

      monthOrders.forEach((whName, sales) {
        if (whName.isEmpty) {
          return;
        }
        widgetsContent.add(
          _InfoRowContent(
              header: whName,
              text: sales > 0
                  ? '$sales шт.'
                  : sales == 0 || justTodayAddedCard
                      ? '-'
                      : sales < -NumericConstants.supplyThreshold
                          ? 'поставка ${-sales} шт.'
                          : 'возврат ${-sales} шт.'),
        );
      });
      children = widgetsContent
          .map((e) => _InfoRow(
                content: e,
                parentContext: context,
                isDark: widgetsContent.indexOf(e) % 2 != 0,
              ))
          .toList();

      children.add(
        _InfoRowTile(
            content: _InfoRowContent(header: '', text: ''),
            text: 'За $month',
            parentContext: context),
      );
    }
    if (widget.index == 7) {
      // Индекс для раздела "Ключевые слова"
      final keywords = model.keywords;
      if (keywords.isEmpty) {
        children = [
          Padding(
            padding: EdgeInsets.all(model.screenWidth * 0.05),
            child: Text(
              'Ключевые слова не найдены.',
              style: TextStyle(
                fontSize: model.screenWidth * 0.04,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ];
      } else {
        children = [
          Padding(
            padding: EdgeInsets.all(model.screenWidth * 0.05),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по ключевым словам',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredKeywords.length,
            itemBuilder: (context, index) {
              final kw = _filteredKeywords[index];
              return Card(
                margin: EdgeInsets.symmetric(
                    vertical: 4.0, horizontal: model.screenWidth * 0.05),
                child: ListTile(
                  title: Text(
                    kw.keyword,
                    style: TextStyle(
                      fontSize: model.screenWidth * 0.045,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Частотность: ${kw.freq}',
                    style: TextStyle(
                      fontSize: model.screenWidth * 0.035,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      _showKeywordOptions(
                          context, kw.keyword, model.goToAdBidsScreen);
                    },
                  ),
                  onTap: () {
                    _showKeywordOptions(
                        context, kw.keyword, model.goToAdBidsScreen);
                  },
                ),
              );
            },
          ),
        ];
      }
    }
    return children;
  }

  void _showKeywordOptions(BuildContext context, String keyword,
      void Function(String) goToAdBidsScreen) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Найти на маркетплейсе'),
              onTap: () {
                Navigator.of(context).pop();
                final encodedKeyword = Uri.encodeComponent(keyword);
                html.window.open(
                    'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedKeyword',
                    'wb');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Посмотреть рекламные ставки'),
              onTap: () {
                Navigator.of(context).pop();
                goToAdBidsScreen(keyword);
              },
            ),
          ],
        ),
      ),
    );
  }

  String formateDate(DateTime dateTime) {
    try {
      final DateFormat formatter = DateFormat.MMMMd('ru');
      return formatter.format(dateTime);
    } catch (e) {
      throw RewildError(
        'форматирование даты: $e',
        sendToTg: true,
        name: 'formateDate',
        source: 'SingleCardScreen',
        args: [dateTime],
      );
    }
  }

  String formateDateAsMonth(DateTime dateTime) {
    final DateFormat formatter = DateFormat.MMMM('ru');
    return formatter.format(dateTime);
  }
}

class _InfoRowTile extends _InfoRow {
  final String text;
  const _InfoRowTile({
    required super.content,
    required this.text,
    required super.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        '* $text.',
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _InfoRowContent {
  final String header;
  final String text;
  final Widget? child;
  final bool isClickable;
  final VoidCallback? onTap;
  _InfoRowContent({
    required String header,
    required this.text,
    this.child,
    this.isClickable = false,
    this.onTap,
  }) : header = header.contains("склад продавца") ||
                header.contains(" Склад продавца")
            ? header.replaceFirst("склад продавца", "скл.пр.")
            : header;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.content,
    required this.parentContext,
    this.isDark = false,
  });

  final _InfoRowContent content;
  final bool isDark;

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    Widget textWidget = Text(
      content.text,
      textAlign: TextAlign.end,
      maxLines: 3,
      style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: model.screenWidth * 0.04,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
    );

    if (content.isClickable) {
      textWidget = GestureDetector(
        onTap: content.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              content.text,
              textAlign: TextAlign.end,
              maxLines: 3,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: model.screenWidth * 0.04,
                  color: Colors.blue),
            ),
            Icon(
              Icons.chevron_right,
              size: model.screenWidth * 0.05,
              color: Colors.blue, // links color
            ),
          ],
        ),
      );
    }

    return Container(
      width: model.screenWidth,
      height: model.screenHeight * 0.07,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(parentContext)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.3)
            : Theme.of(parentContext).colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: model.screenWidth * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: model.screenWidth * 0.3,
              child: GestureDetector(
                onTap: () {
                  if (content.header.contains("скл.пр.")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Внимание: данные о заказах со склада продавца могут быть неточными.",
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "${content.header} ${content.header.contains("скл.пр.") ? "⚠" : ""}",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: model.screenWidth * 0.04,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6)),
                ),
              ),
            ),
            SizedBox(
              width: model.screenWidth * 0.6,
              child: content.child ?? textWidget,
            ),
          ],
        ),
      ),
    );
  }
}

class _Name extends StatelessWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final text = context.watch<SingleCardScreenViewModel>().name;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: model.screenWidth * 0.9 - 16,
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  maxLines: 5,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: model.screenWidth * 0.06,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.copy, size: model.screenWidth * 0.04),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Скопировано в буфер обмена')),
              );
            },
          ),
        )
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final feedbacks = model.feedbacks;
    final reviewRating = model.reviewRating;
    final nmId = model.id;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '$reviewRating',
              style: TextStyle(
                  fontSize: model.screenWidth * 0.04,
                  color: Theme.of(context).colorScheme.primary),
            ),
            Icon(
              Icons.star,
              size: model.screenWidth * 0.04,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(
              width: model.screenWidth * 0.02,
            ),
            Text(
              '$feedbacks',
              style: TextStyle(
                  fontSize: model.screenWidth * 0.04,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            html.window.open(
                'https://www.wildberries.ru/catalog/$nmId/detail.aspx', 'wb');
          },
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: model.screenWidth * 0.01),
                child: Text(
                  'Перейти',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: model.screenWidth * 0.035,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: model.screenWidth * 0.07,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _MainPicture extends StatelessWidget {
  const _MainPicture();

  @override
  Widget build(BuildContext context) {
    final img = context.watch<SingleCardScreenViewModel>().img;

    if (img.isEmpty) {
      return const MyProgressIndicator();
    }
    return ReWildNetworkImage(
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
        image: img);
  }
}

class _TopProductsLink extends StatelessWidget {
  const _TopProductsLink();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleCardScreenViewModel>();
    final subject = model.subjectName;
    return GestureDetector(
      onTap: () {
        model.goToSubject();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(model.screenWidth * 0.04),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Какие товары сейчас на пике продаж в категории $subject?',
                style: TextStyle(
                  fontSize: model.screenWidth * 0.045,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: model.screenWidth * 0.07,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
