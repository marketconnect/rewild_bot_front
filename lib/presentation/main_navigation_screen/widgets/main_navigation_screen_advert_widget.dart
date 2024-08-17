import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/empty_api_key.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/widgets/link_btn.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class MainNavigationScreenAdvertWidget extends StatelessWidget {
  const MainNavigationScreenAdvertWidget(
      {super.key,
      required this.adverts,
      required this.apiKeyExists,
      required this.callbackForUpdate,
      required this.balance,
      required this.isLoading,
      required this.budget});

  final Future<void> Function() callbackForUpdate;
  final int? balance;

  final List<Advert> adverts;
  final bool apiKeyExists;
  final bool isLoading;
  final Map<int, int> budget;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: !apiKeyExists
          ? const EmptyApiKey(
              text:
                  'Для работы с рекламным кабинетом WB вам необходимо добавить токен "Продвижение"',
              route: MainNavigationRouteNames.apiKeysScreen,
            )
          : adverts.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.1,
                          ),
                          Text(
                            'Кампании',
                            style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.95),
                    ),
                    if (balance != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Баланс: $balance руб.",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    if (adverts.isNotEmpty)
                      _AllAdvertsWidget(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          // paused: paused,
                          callbackForUpdate: callbackForUpdate,
                          budget: budget,
                          adverts: adverts),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.05),
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          const LinkBtn(
                            text: 'Аналитика',
                            color: Color(0xFF4aa6db),
                            // route: MainNavigationRouteNames
                            //     .advertsAnaliticsNavScreen,
                            route: "MainNavigationRouteNames.allAdvertsScreen",
                            iconData: Icons.auto_graph_outlined,
                          ),
                          LinkBtn(
                            text: 'Ключевые фразы',
                            route:
                                "MainNavigationRouteNames.editAdvertsKeywordsScreen",
                            color: const Color(0xFFdfb446),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                              height: MediaQuery.of(context).size.width * 0.05,
                              child: Image.asset(
                                IconConstant.iconKeyword,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                )
              : isLoading
                  ? const Center(child: MyProgressIndicator())
                  : const EmptyWidget(text: 'Нет активных рекламных кампаний'),
    );
  }
}

class _AllAdvertsWidget extends StatelessWidget {
  const _AllAdvertsWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.adverts,
    required this.budget,
    required this.callbackForUpdate,
  });
  final Future<void> Function() callbackForUpdate;
  final double screenWidth;
  final double screenHeight;
  final List<Advert> adverts;
  final Map<int, int> budget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Активные',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        SizedBox(
            height: screenHeight * 0.25,
            child: ListView.builder(
                // ListView ====================================================
                itemCount: adverts.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final budget = this.budget[adverts[index].campaignId];
                  final isPaused = adverts[index].status == 11;

                  final icon =
                      isPaused ? Icons.toggle_off_outlined : Icons.toggle_on;

                  return GestureDetector(
                    onTap: () async {
                      final res = await Navigator.of(context).pushNamed(
                        "MainNavigationRouteNames.campaignManagementScreen",
                        arguments: adverts[index].campaignId,
                        // adverts[index].type
                        // ),
                      );

                      if (res != null && res as bool) {
                        await callbackForUpdate();
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.2,
                      padding: const EdgeInsets.all(10),
                      margin: index == 0
                          ? EdgeInsets.only(
                              right: screenWidth * 0.03,
                              left: screenWidth * 0.05)
                          : EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.95)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: screenWidth * 0.06,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.01,
                                  ),
                                  Text(
                                      '${AdvertisingConstants.advTypes[adverts[index].type]}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: screenWidth * 0.5,
                                      child: Text(
                                        adverts[index].name,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.05,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (budget != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Бюджет: ${budget.toString()} руб.',
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.only(right: screenWidth * 0.03),
                                width: screenWidth * 0.04,
                                height: screenWidth * 0.04,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.05),
                                    color: isPaused
                                        ? const Color(0xFFececec)
                                        : const Color(0xFF07a1c6)),
                              ),
                              Text(
                                isPaused ? 'Пауза' : 'Активна',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                })),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        Divider(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.95),
        ),
      ],
    );
  }
}
