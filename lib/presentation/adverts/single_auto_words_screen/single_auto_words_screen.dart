import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/utils/extensions/strings.dart';
import 'package:rewild_bot_front/core/utils/text_filed_validator.dart';
import 'package:rewild_bot_front/domain/entities/keyword.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';
import 'package:rewild_bot_front/presentation/adverts/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/my_dialog_header_and_two_btns_widget.dart';
import 'package:rewild_bot_front/widgets/my_dialog_textfield_radio.dart';

// import 'package:rewild/widgets/progress_indicator.dart';

class SingleAutoWordsScreen extends StatefulWidget {
  const SingleAutoWordsScreen({super.key});

  @override
  State<SingleAutoWordsScreen> createState() => _SingleAutoWordsScreenState();
}

class _SingleAutoWordsScreenState extends State<SingleAutoWordsScreen>
    with SingleTickerProviderStateMixin {
  final PageStorageKey keywordsPageStorageKey =
      const PageStorageKey('SingleAutoWordsKeywordsKey');
  final PageStorageKey excludedPageStorageKey =
      const PageStorageKey('SingleAutoWordsExcludedKey');

  TabController? _tabController;
  final ValueNotifier<int?> _expandedTileIndex = ValueNotifier<int?>(null);
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleAutoWordsViewModel>();
    final name = model.name;
    final searchInputOpen = model.searchInputOpen;
    final searchInputToggle = model.toggleSearchInput;
    final hasChanges = model.hasChanges;
    final totalExpense = model.totalExpense;
    final setSearchQuery = model.setSearchQuery;
    final loading = model.isLoading;
    // final loadingText = model.loadingText;
    return OverlayLoaderWithAppIcon(
      isLoading: loading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          appBar: AppBar(
            // title: Text(
            //     '${name!.capitalize()} ${totalExpense != null ? '(${totalExpense.toStringAsFixed(0)} ₽)' : ''}'),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name!.capitalize(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (totalExpense != null)
                    TextSpan(
                      text:
                          // ' (${totalExpense.toStringAsFixed(0)} ₽ (CPM ${model.cpm}))',
                          ' (CPM ${model.cpm}₽)',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (!hasChanges) {
                    Navigator.of(context).pop();
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext buildContext) {
                      return MyDialogHeaderAndTwoBtnsWidget(
                        onNoPressed: () {
                          if (buildContext.mounted) {
                            Navigator.of(buildContext).pop();
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        onYesPressed: () async {
                          await model.save();
                          if (buildContext.mounted) {
                            Navigator.of(buildContext).pop();
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        title: 'Сохранить изменения?',
                      );
                    },
                  );
                }),
            actions: loading
                ? null
                : [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'update') {
                          model.update(); // Call the update method
                        } else if (value == 'search') {
                          searchInputToggle();
                        } else if (value == 'cpm') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MyDialogTextFieldRadio(
                                addGroup: (
                                    {required String value,
                                    required int option}) async {
                                  model.changeCpm(
                                    value: value,
                                    option: option,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                header: "Ставка (СРМ, ₽)",
                                description: "Введите новое значение ставки",
                                btnText: "Обновить",
                                radioOptions: {
                                  1: model.subjectName,
                                },
                                textInputOptions: {
                                  1: "${model.cpm ?? 0}₽",
                                },
                                validator:
                                    TextFieldValidator.isNumericAndGreaterThanN,
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'cpm',
                            child: Row(
                              children: [
                                Text('CPM',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'update',
                            child: Row(
                              children: [
                                Text('Обновить',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'search',
                            child: Row(
                              children: [
                                Text('Поиск',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                              ],
                            ),
                          ),
                        ];
                      },
                      icon: Icon(Icons.more_vert,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
            bottom: searchInputOpen
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            autofocus: true,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              color: Theme.of(context).primaryColor,
                            ),
                            cursorColor: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.3),
                            onChanged: (value) {
                              setSearchQuery(value);
                            },
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              onPressed: () {
                                searchInputToggle();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Ключевые фразы'),
                      Tab(text: 'Минус фразы'),
                    ],
                  ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildClusterListView(
                model.keywordClusters,
                false,
                loading,
              ),
              _buildClusterListView(
                model.excludedClusters,
                true,
                loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClusterListView(
    Map<String, List<Keyword>> clusters,
    bool isExcluded,
    bool isLoading,
  ) {
    final model = context.watch<SingleAutoWordsViewModel>();
    // create a list of sorted keys based on _sumTodaySum
    var sortedKeys = clusters.keys.toList()
      ..sort((k1, k2) => model
          .sumTodaySum(clusters[k2]!)
          .compareTo(model.sumTodaySum(clusters[k1]!)));

    // if (isLoading) {
    //   return MyProgressIndicator(text: loadingText);
    // }

    return ListView.builder(
      key: isExcluded ? excludedPageStorageKey : keywordsPageStorageKey,
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        // String clusterKey = clusters.keys.elementAt(index);
        // List<Keyword> clusterKeywords = clusters[clusterKey]!;
        String clusterKey = sortedKeys[index];
        List<Keyword> clusterKeywords = clusters[clusterKey]!;

        return _buildTabViewContent(clusterKey, clusterKeywords, isExcluded);
      },
      physics: const ClampingScrollPhysics(),
    );
  }

  Widget _buildTabViewContent(
      String clusterKey, List<Keyword> clusterKeywords, bool isExcluded) {
    final model = context.read<SingleAutoWordsViewModel>();
    final addToOnlineRestKWPositionsInfoForCluster =
        model.addToOnlineRestKWPositionsInfoForCluster;
    final allNmIdsImages = model.allNmIdsImages;
    final onlineRestKWPositionsInfoForCluster =
        model.onlineRestKWPositionsInfoForCluster;

    final searchQuery = model.searchQuery.toLowerCase();
    final clasterNameCpmPositions = model.clasterNameCpmPositions;
    final filteredKeywords = clusterKeywords
        .where((keyword) => keyword.keyword.toLowerCase().contains(searchQuery))
        .toList();

    if (filteredKeywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<int?>(
      valueListenable: _expandedTileIndex,
      builder: (context, expandedIndex, _) {
        bool isExpanded = expandedIndex == clusterKey.hashCode;
        IconData iconData = isExpanded
            ? Icons.keyboard_arrow_down
            : Icons.keyboard_arrow_right_outlined;
        BoxDecoration decoration = _getDecoration(isExpanded, context);
        final clNameCpmPositions = clasterNameCpmPositions[clusterKey];
        return Stack(
          children: [
            Container(
              decoration: decoration,
              child: ExpansionTile(
                key: PageStorageKey<String>(clusterKey),
                initiallyExpanded: isExpanded,
                onExpansionChanged: (bool expanded) async {
                  _expandedTileIndex.value =
                      expanded ? clusterKey.hashCode : null;
                  if (expanded) {
                    await addToOnlineRestKWPositionsInfoForCluster(
                        clusterKeywords);
                  }
                },
                trailing: Icon(iconData,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                title: _buildExpansionTileTitle(clusterKey, filteredKeywords),
                children: filteredKeywords.map((keyword) {
                  final keywordWbLogs =
                      onlineRestKWPositionsInfoForCluster(keyword.keyword);

                  return _buildExpansionTileChild(isExcluded, model, keyword,
                      clusterKey, context, keywordWbLogs, allNmIdsImages);
                }).toList(),
              ),
            ),
            clNameCpmPositions != null && clNameCpmPositions.isNotEmpty
                ? Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        _showTipDialog(context, clNameCpmPositions, clusterKey);
                      },
                    ))
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Slidable _buildExpansionTileChild(
      bool isExcluded,
      SingleAutoWordsViewModel model,
      Keyword keyword,
      String clusterKey,
      BuildContext context,
      Map<int, WbSearchLog> keywordWbLogs,
      String Function(int nmId) allNmIdsImages) {
    // print('keywordWbLogs ${keyword.keyword} ${keywordWbLogs.length}');
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              if (isExcluded) {
                model.moveToKeywords(keyword.keyword, clusterKey);
              } else {
                model.moveToExcluded(keyword.keyword, clusterKey);
              }
            },
            backgroundColor: isExcluded ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
            icon: isExcluded ? Icons.add : Icons.remove,
            label: isExcluded ? 'Восстановить' : 'Исключить',
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ))),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keyword.keyword,
                  ),
                  if (keywordWbLogs.keys.isNotEmpty)
                    Column(
                      children: keywordWbLogs.keys.map((nmId) {
                        final imgUrl = allNmIdsImages(nmId);
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(
                            MainNavigationRouteNames.singleCardScreen,
                            arguments: nmId,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Image.network(imgUrl,
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                    height: MediaQuery.of(context).size.width *
                                        0.05,
                                    fit: BoxFit.cover),
                              ),
                              Text(
                                (keywordWbLogs[nmId]!.position + 1).toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                              Icon(
                                Icons.arrow_right_alt_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              Text(
                                  (keywordWbLogs[nmId]!.promoPosition + 1)
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Text("${keywordWbLogs[nmId]!.cpm} ₽",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ))
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  Text(
                      keyword.todayViews > 0
                          ? 'запросов: ${keyword.todayViews}'
                          : '-',
                      style: const TextStyle(
                        fontSize: 14,
                      )),
                  if (keyword.todayClicks > 0)
                    Text('переходов: ${keyword.todayClicks}',
                        style: const TextStyle(
                          fontSize: 14,
                        )),
                  if (keyword.todaySum > 0)
                    Text('сумма: ${keyword.todaySum} ₽',
                        style: const TextStyle(
                          fontSize: 14,
                        )),
                ],
              ),
              subtitle:
                  keyword.count > 0 ? Text('Запросов: ${keyword.count}') : null,
              trailing: GestureDetector(
                onTap: () {
                  if (isExcluded) {
                    model.moveToKeywords(keyword.keyword, clusterKey);
                  } else {
                    model.moveToExcluded(keyword.keyword, clusterKey);
                  }
                },
                child: Icon(
                  isExcluded
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.5),
                  size: MediaQuery.of(context).size.height * 0.04,
                ),
              ),
            ),
          ),
          if (keyword.isNew && !isExcluded)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.01,
              right: MediaQuery.of(context).size.height * 0.01,
              child: const Icon(
                Icons.star,
                color: Colors.orange,
                size: 10,
              ),
            )
        ],
      ),
    );
  }

  BoxDecoration _getDecoration(bool isExpanded, BuildContext context) {
    BoxDecoration decoration;
    if (isExpanded) {
      decoration = BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary, // Red color for the left border
            width: 5, // Width of the border
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      );
    } else {
      decoration = BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      );
    }
    return decoration;
  }

  void _showTipDialog(
      BuildContext context, List<(int, int, int)> cmpPos, String clusterKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(clusterKey),
          content: DataTable(
            columnSpacing: 0,
            horizontalMargin: 0,
            dividerThickness: 0,
            headingRowHeight: MediaQuery.of(context).size.width * 0.1,
            columns: const [
              DataColumn(label: Text('CPM')),
              DataColumn(label: Text('Позиция')),
              DataColumn(label: Text('Промо')),
            ],
            rows: cmpPos
                .map((e) => DataRow(cells: [
                      DataCell(Text(
                        e.$1.toString(),
                      )),
                      DataCell(Text(e.$2.toString())),
                      DataCell(Text(e.$3.toString())),
                    ]))
                .toList(),
          ),
          // Column(
          //   mainAxisSize: MainAxisSize.min,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: const [
          //     Text('cpm   pos -> promo'),
          //     Text('1000  210 -> 30'),
          //     Text('900    410 -> 50'),
          //     Text('870    10   ->   1'),
          //     Text('400    110 -> 32'),
          //     Text('300    100 -> 31'),
          //   ],
          // ),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpansionTileTitle(String clusterKey, List<Keyword> keywords) {
    // Calculate total number of phrases and queries in the cluster
    final model = context.read<SingleAutoWordsViewModel>();

    final clasterWbLogs =
        model.onlineGeneralKWPositionsInfoForCluster(clusterKey);
    final allNmIdsImages = model.allNmIdsImages;
    // final totalPhrases = keywords.length;
    final totalSum =
        keywords.fold(0.0, (sum, keyword) => sum + keyword.todaySum);
    final totalViews =
        keywords.fold(0, (sum, keyword) => sum + keyword.todayViews);
    final totalClicks =
        keywords.fold(0, (sum, keyword) => sum + keyword.todayClicks);
    final totalCtr = totalViews == 0 ? 0 : ((totalClicks / totalViews) * 100);
    // keywords.fold(0.0, (sum, keyword) => sum + keyword.todayCtr);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display cluster key, show 'Без кластера' if empty
          Text(clusterKey.isEmpty ? 'Без кластера' : clusterKey,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )),
          if (clasterWbLogs.keys.isNotEmpty)
            Column(
              children: clasterWbLogs.keys.map((nmId) {
                final imgUrl = allNmIdsImages(nmId);

                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    MainNavigationRouteNames.singleCardScreen,
                    arguments: nmId,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image.network(imgUrl,
                            width: MediaQuery.of(context).size.width * 0.05,
                            height: MediaQuery.of(context).size.width * 0.05,
                            fit: BoxFit.cover),
                      ),
                      Text(
                        (clasterWbLogs[nmId]!.position + 1).toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      Text((clasterWbLogs[nmId]!.promoPosition + 1).toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("${clasterWbLogs[nmId]!.cpm} ₽",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ))
                    ],
                  ),
                );
              }).toList(),
            ),
          // Total phrases
          // Text('Всего фраз: $totalPhrases',
          //     style: TextStyle(
          //       color: Theme.of(context).colorScheme.onPrimaryContainer,
          //       fontSize: 14,
          //     )),
          // Total queries
          Text('Всего показов: $totalViews',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 14,
              )),
          Text('Всего переходов: $totalClicks',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 14,
              )),
          Text('CTR: ${totalCtr.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 14,
              )),
          Text('Всего потрачено: ${totalSum.toStringAsFixed(2)} ₽',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
