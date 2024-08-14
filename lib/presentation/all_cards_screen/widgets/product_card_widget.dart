// import 'package:flutter/material.dart';
// import 'package:rewild_bot_front/core/utils/extensions/strings.dart';
// import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';
// import 'package:rewild_bot_front/domain/entities/hive/group_model.dart';
// import 'package:rewild_bot_front/widgets/network_image.dart';

// class ProductCardWidget extends StatelessWidget {
//   const ProductCardWidget({
//     super.key,
//     required this.productCard,
//     required this.userNmId,
//     required this.isNotPaid,
//     this.inAnyGroup = false,
//     this.isSelected = false,
//     required this.grossProfit,
//     this.isShimmer = false,
//   });

//   final CardOfProduct productCard;
//   final bool isSelected;
//   final bool inAnyGroup;
//   final bool isShimmer;
//   final bool isNotPaid;
//   final bool userNmId;
//   final double? grossProfit;

//   bool isToday(int? millisecondsSinceEpoch) {
//     if (millisecondsSinceEpoch == null) {
//       return false;
//     }
//     DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
//     DateTime now = DateTime.now();

//     // Убедитесь, что сравниваемые даты имеют одинаковый год, месяц и день.
//     return date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final stocksSum = productCard.stocksSum;
//     final salesSum = productCard.weekOrdersSum;
//     final price = productCard.basicPriceU ?? 0;
//     final wasSaled = productCard.wasOrdered;
//     final promoTextCard = productCard.promoTextCard;
//     final supplySum = productCard.supplySum;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final tracked = productCard.tracked;
//     final justTodayAddedCard = isToday(productCard.createdAt);

//     final supplyText = !isNotPaid &&
//             productCard.supplies.isNotEmpty &&
//             supplySum > 0 &&
//             !justTodayAddedCard
//         ? " "
//         // ? " (п. ~$supplySum шт.)"
//         : "";

//     String? ordersSumText;
//     if (isNotPaid && userNmId) {
//       ordersSumText = "Не отслеживается";
//     } else if (isNotPaid) {
//       ordersSumText = "";
//     } else if (salesSum > 0) {
//       ordersSumText = "Заказы: $salesSum шт.";
//     } else if (salesSum < 0 &&
//         salesSum > -20 &&
//         supplyText.isEmpty &&
//         !justTodayAddedCard) {
//       ordersSumText = "Возврат: ${salesSum.abs()} шт.";
//     } else {
//       ordersSumText = "";
//     }

//     return Card(
//         margin: const EdgeInsets.all(0),
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(3))),
//         color: isSelected
//             ? Theme.of(context).colorScheme.surfaceContainerHighest
//             : Colors.transparent,
//         elevation: 0,
//         surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
//         child: ClipPath(
//           child: Stack(children: [
//             Container(
//               padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
//               decoration: BoxDecoration(
//                   border: Border(
//                       bottom: BorderSide(
//                 color: Theme.of(context).colorScheme.surfaceContainerHighest,
//               ))),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       ReWildNetworkImage(
//                           width: screenWidth * 0.2,
//                           image: productCard.img ?? ""),
//                       const SizedBox(
//                         width: 3,
//                       ),
//                       SizedBox(
//                         width: screenWidth * 0.6,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 SizedBox(
//                                   width:
//                                       productCard.groups.isEmpty || inAnyGroup
//                                           ? screenWidth * 0.6
//                                           : screenWidth * 0.45,
//                                   child: isShimmer
//                                       ? Container(
//                                           width: screenWidth * 0.2,
//                                           height: screenHeight * 0.02,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface,
//                                           ),
//                                         )
//                                       : Text(productCard.name,
//                                           overflow: TextOverflow.ellipsis),
//                                 ),
//                                 inAnyGroup
//                                     ? Container()
//                                     : _Groups(groups: productCard.groups)
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Row(
//                               children: [
//                                 isShimmer
//                                     ? Container(
//                                         width: screenWidth * 0.2,
//                                         height: screenHeight * 0.02,
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .onSurface,
//                                         ),
//                                       )
//                                     : isNotPaid && !userNmId
//                                         ? Text('Не отслеживается',
//                                             style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .colorScheme
//                                                     .error,
//                                                 fontSize: screenWidth * 0.035))
//                                         : Text('Остатки: $stocksSum шт.',
//                                             style: TextStyle(
//                                                 color: const Color(0xFFa1a1a2),
//                                                 fontSize: screenWidth * 0.035)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Row(
//                                   children: [
//                                     isShimmer
//                                         ? Container(
//                                             width: screenWidth * 0.25,
//                                             height: screenHeight * 0.02,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .onSurface,
//                                             ),
//                                           )
//                                         : Text(ordersSumText,
//                                             style: TextStyle(
//                                                 color: const Color(0xFFa1a1a2),
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: MediaQuery.of(context)
//                                                         .size
//                                                         .width *
//                                                     0.035)),
//                                     if (wasSaled)
//                                       const Padding(
//                                         padding: EdgeInsets.only(left: 8.0),
//                                         child: Icon(Icons.arrow_outward_rounded,
//                                             size: 20, color: Color(0xFF34d058)),
//                                       ),
//                                     SizedBox(
//                                       width: screenWidth * 0.2,
//                                       child: Text(
//                                         supplyText,
//                                         style: TextStyle(
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .error,
//                                             fontSize: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.035),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     width: screenWidth * 0.15,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         isShimmer
//                             ? Container(
//                                 width: screenWidth * 0.1,
//                                 height: screenHeight * 0.02,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5),
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                 ),
//                               )
//                             : Text(isNotPaid ? "" : '${(price / 100).floor()}₽',
//                                 style: TextStyle(fontSize: screenWidth * 0.03)),
//                         if (!isNotPaid &&
//                             promoTextCard != null &&
//                             promoTextCard != "")
//                           Container(
//                               margin: const EdgeInsets.fromLTRB(0, 5, 5, 0),
//                               alignment: Alignment.center,
//                               width: screenWidth * 0.2,
//                               height: screenWidth * 0.05,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(2),
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .errorContainer,
//                               ),
//                               child: Text("Акция",
//                                   style: TextStyle(
//                                       fontSize: screenWidth * 0.03,
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .error))),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             if (tracked)
//               Positioned(
//                 right: screenWidth * 0.02,
//                 top: screenWidth * 0.02,
//                 child: Icon(
//                   Icons.notifications_active_sharp,
//                   size: screenWidth * 0.03,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//             if (grossProfit != null && !isNotPaid)
//               Positioned(
//                 right: screenWidth * 0.02,
//                 bottom: screenWidth * 0.02,
//                 child: Text(
//                   '${grossProfit! > 0 ? '+' : ''} ${grossProfit!.floor() * salesSum} ₽',
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.03,
//                     color: grossProfit! < 0
//                         ? Theme.of(context).colorScheme.error
//                         : Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ),
//           ]),
//         ));
//   }
// }

// class _Groups extends StatelessWidget {
//   const _Groups({
//     required this.groups,
//   });

//   final List<GroupModel> groups;

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Column(
//         children: groups.isEmpty
//             ? [Container()]
//             : [
//                 Container(
//                   alignment: Alignment.center,
//                   width: screenWidth * 0.1,
//                   height: 18,
//                   decoration: BoxDecoration(
//                       color: Color(groups[0].bgColor).withOpacity(1.0),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: SizedBox(
//                     width: screenWidth * 0.08,
//                     child: Text(groups[0].name.take(4).toLowerCase(),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 7,
//                           fontWeight: FontWeight.bold,
//                           color: Color(groups[0].fontColor),
//                         )),
//                   ),
//                 ),
//                 groups.length > 1
//                     ? Text(
//                         '+${groups.length - 1}',
//                         style: const TextStyle(
//                           fontSize: 7,
//                           color: Color(0xFF1f1f1f),
//                         ),
//                       )
//                     : Container(),
//               ]);
//   }
// }
