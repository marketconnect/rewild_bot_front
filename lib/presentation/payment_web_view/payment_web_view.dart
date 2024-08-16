import 'package:flutter/material.dart';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/domain/entities/payment_info.dart';
import 'package:rewild_bot_front/presentation/payment_web_view/payment_webview_model.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class PaymentWebView extends StatefulWidget {
  final PaymentInfo paymentInfo;

  const PaymentWebView({
    super.key,
    required this.paymentInfo,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  bool _isLoading = true;
  String viewID = '';

  @override
  void initState() {
    super.initState();
    _initializeIFrame();
  }

  void _initializeIFrame() {
    // Генерация уникального ID для каждого IFrame
    viewID = 'iframe_${DateTime.now().millisecondsSinceEpoch}';

    final String urlWithParams =
        '${ServerConstants.siteUrl}/оплата?amount=${widget.paymentInfo.amount}&description=${Uri.encodeComponent(widget.paymentInfo.description)}';

    final IFrameElement iframeElement = IFrameElement()
      ..src = urlWithParams
      ..style.border = 'none'
      ..onLoad.listen((event) {
        setState(() {
          _isLoading = false;
        });
      });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewID,
      (int viewId) => iframeElement,
    );

    window.onMessage.listen((event) {
      if (event.data != null) {
        _checkUrlAndPerformAction(event.data.toString());
      }
    });
  }

  void _checkUrlAndPerformAction(String url) {
    final model = context.read<PaymentWebViewModel>();
    final balanceSuccess = model.balanceSuccess;
    final successCallback = model.successCallback;
    final errorCallback = model.errorCallback;
    final cardModels = widget.paymentInfo.cards;
    final amount = widget.paymentInfo.amount;
    final endDate = widget.paymentInfo.endDate;
    final onlybalance = widget.paymentInfo.onlyBalance;

    if (url.startsWith('https://marketconnect.ru/success')) {
      if (onlybalance) {
        balanceSuccess(amount: amount.toDouble());
      } else {
        successCallback(
            amount: amount, cardModels: cardModels, endDate: endDate);
      }
    } else if (url.startsWith('https://marketconnect.ru/error')) {
      errorCallback(amount, cardModels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: HtmlElementView(
          viewType: viewID,
        ),
      ),
      if (_isLoading)
        const Opacity(
          opacity: 0.8,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
      if (_isLoading)
        const Center(
          child: MyProgressIndicator(isDark: true),
        ),
    ]);
  }
}
