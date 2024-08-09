import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:rewild_bot_front/.env.dart';

class MainNavigationScreenHomeWidget extends StatefulWidget {
  const MainNavigationScreenHomeWidget({super.key, required this.userName});
  final Future<String> Function() userName;
  @override
  State<MainNavigationScreenHomeWidget> createState() =>
      _MainNavigationScreenHomeWidgetState();
}

class _MainNavigationScreenHomeWidgetState
    extends State<MainNavigationScreenHomeWidget> {
  // late bool feedBackExpanded;
  // late bool showThankYouMessage;
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    // feedBackExpanded = false;
    // showThankYouMessage = false;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // void feedBackExpandedToggle() {
  //   setState(() {
  //     feedBackExpanded = !feedBackExpanded;
  //   });
  // }

  // Future<void> sendFeedback() async {
  //   final messageText = _controller.text;
  //   if (messageText.isEmpty) {
  //     return;
  //   }
  //   setState(() {
  //     feedBackExpanded = false;
  //     showThankYouMessage = true; // Set to true when feedback is sent
  //   });
  //   await widget.sendFeedback(messageText);
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
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
                'Главная',
                style: TextStyle(
                    fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.3),
          ),
          child: Column(
            children: [
              const _Link(
                text: 'Условия использования',
                color: Color(0xFFF44336),
                route: "MainNavigationRouteNames.termsOfServiceScreen",
                iconData: Icons.verified_user,
              ),
              const _Link(
                text: 'Уведомления',
                color: Color(0xFFfb8532),
                route: "MainNavigationRouteNames.backgroundNotificationsScreen",
                iconData: Icons.share_arrival_time_outlined,
              ),
              const _Link(
                text: 'API токены',
                color: Color(0xFF41434e),
                route: "MainNavigationRouteNames.apiKeysScreen",
                iconData: Icons.key,
              ),
              // const _LinkBrowser(
              //   text: 'Наш сайт',
              //   color: Color(0xFFf9c513),
              //   // route: "MainNavigationRouteNames.userInfoScreen",
              //   route: '',
              //   iconData: Icons.emoji_emotions_outlined,
              // ),
              _Feedback(
                click: () => submitFeedBack(),
              ),
              // !feedBackExpanded
              //     ? Container()
              //     : !showThankYouMessage
              //         ? Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 15.0),
              //             child: Column(
              //               children: [
              //                 SizedBox(
              //                   height: screenHeight * 0.02,
              //                 ),
              //                 Row(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: [
              //                     Text(
              //                       "Напишите нам",
              //                       style: TextStyle(
              //                           fontSize: screenWidth * 0.06,
              //                           fontWeight: FontWeight.bold),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: screenHeight * 0.02,
              //                 ),
              //                 Row(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: [
              //                     Text(
              //                       "Пожелание в свободной форме:",
              //                       style: TextStyle(
              //                           fontSize: screenWidth * 0.045),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: screenHeight * 0.01,
              //                 ),
              //                 Container(
              //                   width: screenWidth * 0.96,
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(10),
              //                     color: Theme.of(context).colorScheme.surface,
              //                   ),
              //                   child: TextField(
              //                     controller: _controller,
              //                     maxLines: null, // Allows unlimited lines
              //                     minLines: 3,
              //                     decoration: InputDecoration(
              //                       // hintText: 'Enter your text here',
              //                       border: OutlineInputBorder(
              //                           // borderRadius: BorderRadius.circular(10.0),
              //                           borderSide: BorderSide(
              //                         color:
              //                             Theme.of(context).colorScheme.surface,
              //                       )),
              //                     ),
              //                   ),
              //                 ),
              //                 SizedBox(
              //                   height: screenHeight * 0.05,
              //                 ),
              //                 ElevatedButton(
              //                   onPressed: () {
              //                     sendFeedback();
              //                   },
              //                   style: ElevatedButton.styleFrom(
              //                       backgroundColor:
              //                           Theme.of(context).colorScheme.surface,
              //                       surfaceTintColor:
              //                           Theme.of(context).colorScheme.surface,
              //                       foregroundColor: Theme.of(context)
              //                           .colorScheme
              //                           .onSurfaceVariant,
              //                       elevation:
              //                           3, // Adjust the shadow elevation as needed
              //                       shadowColor:
              //                           Colors.grey, // Set the shadow color
              //                       shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(10),
              //                       ),
              //                       side: BorderSide(
              //                         width: 1.0,
              //                         color: Theme.of(context)
              //                             .colorScheme
              //                             .onSurface,
              //                       )),
              //                   child: Padding(
              //                     padding:
              //                         const EdgeInsets.symmetric(vertical: 15),
              //                     child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.center,
              //                       children: [
              //                         Container(
              //                             decoration: BoxDecoration(
              //                               color: Theme.of(context)
              //                                   .colorScheme
              //                                   .primary,
              //                               borderRadius:
              //                                   BorderRadius.circular(50),
              //                             ),
              //                             padding: const EdgeInsets.all(5),
              //                             child: Icon(
              //                               Icons.send_sharp,
              //                               size: 15,
              //                               color: Theme.of(context)
              //                                   .colorScheme
              //                                   .surface,
              //                             )),
              //                         const SizedBox(
              //                           width: 10,
              //                         ),
              //                         const Text('Отправить сообщение',
              //                             style: TextStyle(
              //                                 fontWeight: FontWeight.bold)),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //                 SizedBox(
              //                   height: screenHeight * 0.07,
              //                 ),
              //               ],
              //             ),
              //           )
              //         : Center(
              //             child: Padding(
              //               padding: EdgeInsets.symmetric(
              //                   horizontal: screenWidth * 0.05,
              //                   vertical: screenHeight * 0.05),
              //               child: Text(
              //                   "Спасибо, что вы нашли время поделиться своими мыслями и предложениями. ",
              //                   style: TextStyle(
              //                       fontSize: screenWidth * 0.05,
              //                       fontWeight: FontWeight.w600)),
              //             ),
              //           ),
            ],
          ),
        )
      ]),
    );
  }

  void submitFeedBack() async {
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      final screenshot = feedback.screenshot;
      final feedbackText = feedback.text;

      // Convert screenshot to Uint8List
      final Uint8List screenshotBytes = Uint8List.fromList(screenshot);

      // Send the feedback to Telegram
      const telegramApiUrl =
          'https://api.telegram.org/bot${TBot.tBotFeedbackToken}/sendPhoto';
      const telegramChatId = TBot.tBotFeedbackChatId;
      final userName = await widget.userName();
      var request = http.MultipartRequest('POST', Uri.parse(telegramApiUrl))
        ..fields['chat_id'] = telegramChatId
        ..fields['caption'] = '$userName\n$feedbackText'
        ..files.add(http.MultipartFile.fromBytes(
          'photo',
          screenshotBytes,
          filename: 'screenshot.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));

      final response = await request.send();

      if (response.statusCode != 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось отправить отзыв'),
          ),
        );
      }
    });
  }
}

// class _LinkBrowser extends StatelessWidget {
//   const _LinkBrowser({
//     required this.text,
//     required this.route,
//     required this.iconData,
//     required this.color,
//   });

//   final String text;

//   final String route;
//   final IconData iconData;
//   final Color color;
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return GestureDetector(
//       onTap: () async {
//         if (await canLaunchUrl(Uri.parse(ServerConstants.siteUrl))) {
//           await launchUrl(Uri.parse(ServerConstants.siteUrl));
//         } else {
//           throw 'Could not launch ${ServerConstants.siteUrl}';
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
//         decoration: BoxDecoration(
//             border: Border.all(color: Colors.transparent),
//             color: Theme.of(context).colorScheme.surface),
//         child: Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   color: color, borderRadius: BorderRadius.circular(10)),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Icon(
//                   iconData,
//                   color: Theme.of(context).colorScheme.surface,
//                   size: screenWidth * 0.05,
//                 ),
//               ),
//             ),
//             SizedBox(
//               width: screenWidth * 0.05,
//             ),
//             Text(
//               text,
//               style: TextStyle(
//                   fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class _Link extends StatelessWidget {
  const _Link({
    required this.text,
    required this.route,
    required this.iconData,
    required this.color,
  });

  final String text;

  final String route;
  final IconData iconData;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context).colorScheme.surface),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  iconData,
                  color: Theme.of(context).colorScheme.surface,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.click});
  final Function click;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => click(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context).colorScheme.surface),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF2188ff),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.feedback_outlined,
                  color: Theme.of(context).colorScheme.surface,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              "Обратная связь",
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
