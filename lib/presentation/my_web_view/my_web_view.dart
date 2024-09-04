import 'dart:ui_web';

import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/utils/extensions/strings.dart';
import 'package:rewild_bot_front/presentation/my_web_view/my_web_view_screen_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';
import 'package:web/web.dart' as html;
import 'dart:js_interop';

class MyWebViewScreen extends StatefulWidget {
  const MyWebViewScreen({super.key, required this.nmIds, this.searchString});
  final List<int> nmIds;
  final String? searchString;

  @override
  State<MyWebViewScreen> createState() => _MyWebViewScreenState();
}

class _MyWebViewScreenState extends State<MyWebViewScreen> {
  String currentUrl = "";
  String mes = "";
  bool _isLoading = true;
  late final String viewID;

  @override
  void initState() {
    super.initState();
    viewID = 'iframe_${DateTime.now().millisecondsSinceEpoch}';
    _initializeIFrame();
  }

  void _initializeIFrame() {
    final String initialUrl = widget.searchString != null
        ? 'https://www.wildberries.ru/catalog/0/search.aspx?search=${widget.searchString}'
        : 'https://www.wildberries.ru';

    final IFrameElement iframeElement = IFrameElement()
      ..src = initialUrl
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
        // Handle custom JavaScript messages here
        mes = event.data.toString();
      }
    });
  }

  // ignore: unused_element
  void _setUrl(String url) {
    setState(() {
      currentUrl = url;
    });
  }

  Future<void> _runJavaScript(String script) async {
    final IFrameElement iframeElement =
        document.getElementById(viewID) as IFrameElement;
    iframeElement.contentWindow?.postMessage(script, '*');
  }

  void dartPrint(String message) {
    print('JS say: $message');
  }

  /// Регистрируем в текущем контексте

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyWebViewScreenViewModel>();
    final save = model.saveSiblingCards;
    final errorMessage = model.errorMessage;

    html.window.open('https://www.wildberries.ru/', 'Google',
        'left=100, top=100, width=500, height=300, popup');
    // html.window.se(
    //   'printOnDart'.toJS,
    //   dartPrint.toJS,
    // );
    return Scaffold(
      appBar: AppBar(
        leadingWidth: model.screenWidth * 0.35,
        leading: TextButton(
            onPressed: () => Navigator.pushReplacementNamed(
                context, MainNavigationRouteNames.allCardsScreen),
            child: SizedBox(
                width: model.screenWidth * 0.35,
                child: const Text('Выйти',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
        actions: [
          currentUrl.isWildberriesDetailUrl()
              ? TextButton(
                  onPressed: () async {
                    await _runJavaScript('runJavaScript();');
                    final n = await save(mes);
                    final message = errorMessage ??
                        (n == 0
                            ? "Эти карточки уже добавлены"
                            : "Добавлено карточек: $n шт.");
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      message,
                    )));
                  },
                  child: const Text('Добавить',
                      style: TextStyle(fontWeight: FontWeight.bold)))
              : const SizedBox()
        ],
        backgroundColor: const Color(0xFFfafafa),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(children: [
        HtmlElementView(
          viewType: viewID,
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
      ]),
    );
  }
}
