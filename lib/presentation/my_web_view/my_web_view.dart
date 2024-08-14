// import 'dart:convert';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rewild_bot_front/core/utils/extensions/strings.dart';
// import 'package:rewild_bot_front/presentation/my_web_view/my_web_view_screen_view_model.dart';
// import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
// import 'package:rewild_bot_front/widgets/progress_indicator.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'dart:ui_web' as ui;

// class MyWebViewScreen extends StatefulWidget {
//   const MyWebViewScreen({super.key, required this.nmIds, this.searchString});
//   final List<int> nmIds;
//   final String? searchString;

//   @override
//   State<MyWebViewScreen> createState() => _MyWebViewScreenState();
// }

// class _MyWebViewScreenState extends State<MyWebViewScreen> {
//   String currentUrl = "";
//   String mes = "";

//   late html.IFrameElement _iframeElement;
//   bool _isLoading = true;

//   void _setUrl(String url) {
//     setState(() {
//       currentUrl = url;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeIFrame();
//   }

//   void _initializeIFrame() {
//     final initialUrl = widget.searchString != null
//         ? 'https://www.wildberries.ru/catalog/0/search.aspx?search=${widget.searchString}'
//         : 'https://www.wildberries.ru';

//     _iframeElement = html.IFrameElement()
//       ..src = initialUrl
//       ..style.border = 'none'
//       ..onLoad.listen((event) {
//         setState(() {
//           _isLoading = false;
//         });
//       })
//       ..onError.listen((event) {
//         print("Error loading IFrame.");
//       });

//     ui.platformViewRegistry.registerViewFactory(
//       'iframeElement',
//       (int viewId) => _iframeElement,
//     );
//   }

//   // JavaScript function to execute on the web page
//   Future<void> _onAddTap() async {
//     _iframeElement.contentWindow!.postMessage('runJavaScript', '*');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<MyWebViewScreenViewModel>();
//     final save = model.saveSiblingCards;
//     final isLoading = model.isLoading;
//     final errorMessage = model.errorMessage;

//     // Добавляем обработчик для сообщений, отправленных из iframe
//     html.window.onMessage.listen((event) {
//       if (event.data != null && event.data is String) {
//         mes = event.data;
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         leadingWidth: model.screenWidth * 0.35,
//         leading: TextButton(
//             onPressed: () => Navigator.pushReplacementNamed(
//                 context, MainNavigationRouteNames.allCardsScreen),
//             child: SizedBox(
//                 width: model.screenWidth * 0.35,
//                 child: const Text('Выйти',
//                     style: TextStyle(fontWeight: FontWeight.bold)))),
//         actions: [
//           currentUrl.isWildberriesDetailUrl()
//               ? TextButton(
//                   onPressed: () async {
//                     await _onAddTap();
//                     final n = await save(mes);
//                     final message = errorMessage ??
//                         (n == 0
//                             ? "Эти карточки уже добавлены"
//                             : "Добавлено карточек: $n шт.");
//                     // ignore: use_build_context_synchronously
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(
//                       message,
//                     )));
//                   },
//                   child: const Text('Добавить',
//                       style: TextStyle(fontWeight: FontWeight.bold)))
//               : const SizedBox()
//         ],
//         backgroundColor: const Color(0xFFfafafa),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Stack(children: [
//         const HtmlElementView(viewType: 'iframeElement'),
//         if (isLoading)
//           const Opacity(
//             opacity: 0.8,
//             child: ModalBarrier(dismissible: false, color: Colors.black),
//           ),
//         if (isLoading)
//           const Center(
//             child: MyProgressIndicator(isDark: true),
//           ),
//       ]),
//     );
//   }
// }
