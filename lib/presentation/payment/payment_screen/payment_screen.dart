import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';

import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen_view_model.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PaymentScreenViewModel>();
    final subscriptions = model.subscriptionsInfo;
    final activeIndex = model.activeIndex;
    final isLoading = model.isLoading;
    final setActive = model.setActive;
    final units = model.units;
    final indexOfCurrentSubscription = model.indexOfCurrentSubscription;
    final processPayment = model.processPayment;
    final todayPlusOneMonth =
        formatDate(model.todayPlusOneMonth.toIso8601String());
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8324FF),
              Color(0xFFFBD4D9),
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: MyProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                      )
                    ]),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Выберите тариф',
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  _SubscriptionsCards(
                      subscriptions: subscriptions,
                      activeIndex: activeIndex,
                      indexOfCurrentSubscription: indexOfCurrentSubscription,
                      todayPlusOneMonth: todayPlusOneMonth,
                      setActive: setActive),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  _Units(units: units, activeIndex: activeIndex),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      processPayment();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 24,
                      height: MediaQuery.of(context).size.height * 0.07,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        indexOfCurrentSubscription == activeIndex
                            ? "Продлить"
                            : "Оплатить",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
      ),
    );
  }
}

class _Units extends StatelessWidget {
  const _Units({
    required this.units,
    required this.activeIndex,
  });

  final List<List<String>> units;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final index =
        activeIndex > units.length - 1 ? units.length - 1 : activeIndex;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: units[index]
            .map((unit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(unit,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _SubscriptionsCards extends StatefulWidget {
  const _SubscriptionsCards({
    required this.subscriptions,
    required this.activeIndex,
    required this.setActive,
    required this.indexOfCurrentSubscription,
    required this.todayPlusOneMonth,
  });

  final List<Map<String, dynamic>> subscriptions;
  final int indexOfCurrentSubscription;
  final int activeIndex;
  final void Function(int value) setActive;
  final String todayPlusOneMonth;

  @override
  State<_SubscriptionsCards> createState() => _SubscriptionsCardsState();
}

class _SubscriptionsCardsState extends State<_SubscriptionsCards> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.activeIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToIndex());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  void _scrollToIndex() {
    final position =
        MediaQuery.of(context).size.height * 0.3 * widget.activeIndex;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 2),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prolongation =
        widget.indexOfCurrentSubscription == widget.activeIndex;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: widget.subscriptions.length,
        itemBuilder: (context, index) {
          final active = index == widget.activeIndex;
          return GestureDetector(
            onTap: () => widget.setActive(
              index,
            ),
            child: Container(
              width: MediaQuery.of(context).size.height * 0.3,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: active
                      ? null
                      : Border.all(
                          width: 2,
                          color: Colors.white.withOpacity(0.9),
                        )),
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.subscriptions[index]['title'],
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.025,
                            color: active ? Colors.black : Colors.white,
                          ),
                        ),
                        if (active)
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.height * 0.025,
                            height: MediaQuery.of(context).size.height * 0.025,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: MediaQuery.of(context).size.height * 0.015,
                              color: Colors.white,
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.subscriptions[index]['price'],
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                            color: active ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.subscriptions[index]['endDate'] != null)
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      prolongation
                                          ? 'Продлить до ${widget.subscriptions[index]['endDatePlusOneMonth']}'
                                          : 'Оплачено до ${widget.subscriptions[index]['endDate']}',
                                      style: TextStyle(
                                        color: active
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                      ))
                                ]),
                          if (widget.subscriptions[index]['endDate'] == null)
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('до ${widget.todayPlusOneMonth}',
                                      style: TextStyle(
                                        color: active
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                      ))
                                ]),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
