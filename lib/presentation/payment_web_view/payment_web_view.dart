// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rewild_bot_front/.env.dart';
// import 'package:rewild_bot_front/domain/entities/payment_info.dart';
// import 'package:rewild_bot_front/presentation/payment_web_view/payment_webview_model.dart';
// import 'package:rewild_bot_front/widgets/progress_indicator.dart';
// // import 'package:webview_flutter/webview_flutter.dart';

// class PaymentWebView extends StatefulWidget {
//   final PaymentInfo paymentInfo;

//   const PaymentWebView({
//     super.key,
//     required this.paymentInfo,
//   });

//   @override
//   State<PaymentWebView> createState() => _PaymentWebViewState();
// }

// class _PaymentWebViewState extends State<PaymentWebView> {
//   bool _isLoading = true;

//   // final WebViewController _webViewController = WebViewController();

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _webViewController
//   //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//   //     ..setNavigationDelegate(
//   //       NavigationDelegate(
//   //         onPageStarted: (String url) {
//   //           setState(() {
//   //             _isLoading = true;
//   //           });
//   //           _checkUrlAndPerformAction(url);
//   //         },
//   //         onPageFinished: (String url) async {
//   //           await _webViewController.runJavaScript("""
//   //           document.querySelector('input[name="amount"]').value = ${widget.paymentInfo.amount};
//   //           document.querySelector('input[name="description"]').value = "${widget.paymentInfo.description}";
//   //         """);
//   //           setState(() {
//   //             _isLoading = false;
//   //           });
//   //         },
//   //         onWebResourceError: (WebResourceError error) {},
//   //         onNavigationRequest: (NavigationRequest request) {
//   //           _checkUrlAndPerformAction(request.url);
//   //           return NavigationDecision.navigate;
//   //         },
//   //       ),
//   //     )
//   //     ..loadRequest(Uri.parse('${ServerConstants.siteUrl}/оплата'));
//   // }

//   void _checkUrlAndPerformAction(String url) {
//     final model = context.read<PaymentWebViewModel>();
//     final balanceSuccess = model.balanceSuccess;
//     final successCallback = model.successCallback;
//     final errorCallback = model.errorCallback;
//     final cardModels = widget.paymentInfo.cards;
//     final amount = widget.paymentInfo.amount;
//     final endDate = widget.paymentInfo.endDate;
//     final onlybalance = widget.paymentInfo.onlyBalance;
//     if (url.startsWith('https://marketconnect.ru/success')) {
//       if (onlybalance) {
//         balanceSuccess(amount: amount.toDouble());
//       } else {
//         successCallback(
//             amount: amount, cardModels: cardModels, endDate: endDate);
//       }
//     } else if (url.startsWith('https://marketconnect.ru/error')) {
//       errorCallback(amount, cardModels);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final model = context.read<PaymentWebViewModel>();
//     // final successCallback = model.successCallback;
//     // final balanceSuccess = context.read<PaymentWebViewModel>().balanceSuccess;

//     // final cardModels = widget.paymentInfo.cards;
//     // final amount = widget.paymentInfo.amount;
//     // final endDate = widget.paymentInfo.endDate;
//     return Stack(children: [
//       Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               icon: const Icon(Icons.arrow_back),
//             ),
//           ),
//           body: Center(
//             child: TextButton(
//               onPressed: () async {},
//               child: const Text('Оплатить'),
//             ),
//           )
//           //
//           //     WebViewWidget(
//           //   controller: _webViewController,
//           // ),

//           ),
//       if (_isLoading)
//         const Opacity(
//           opacity: 0.8,
//           child: ModalBarrier(dismissible: false, color: Colors.black),
//         ),
//       if (_isLoading)
//         const Center(
//           child: MyProgressIndicator(isDark: true),
//         ),
//     ]);
//   }
// }
