import 'package:flutter/material.dart';

class RewildTextEdittingController extends TextEditingController {
  List<String> listErrorTexts;

  RewildTextEdittingController({super.text, this.listErrorTexts = const []});

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final List<TextSpan> children = [];
    if (listErrorTexts.isEmpty) {
      return TextSpan(text: text, style: style);
    }
    try {
      // Use word boundaries to match only whole words
      String pattern = r'(\b' + listErrorTexts.join(r'\b|\b') + r'\b)';
      RegExp regExp = RegExp(
        pattern,
        unicode: true, // Enable Unicode handling
      );

      text.splitMapJoin(regExp, onMatch: (m) {
        children.add(TextSpan(
          text: m[0],
          style: style?.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: Colors.red),
        ));
        return "";
      }, onNonMatch: (n) {
        children.add(TextSpan(text: n, style: style));
        return "";
      });
    } on Exception catch (_) {
      return TextSpan(text: text, style: style);
    }

    // try {
    //   // Adjust the RegExp to handle Russian words
    //   String pattern = '(${listErrorTexts.join('|')})';
    //   RegExp regExp = RegExp(
    //     pattern,
    //     unicode: true, // Enable Unicode handling
    //   );

    //   text.splitMapJoin(regExp, onMatch: (m) {
    //     children.add(TextSpan(
    //       text: m[0],
    //       style: style?.copyWith(
    //           decoration: TextDecoration.underline,
    //           decorationStyle: TextDecorationStyle.wavy,
    //           decorationColor: Colors.red),
    //     ));
    //     return "";
    //   }, onNonMatch: (n) {
    //     children.add(TextSpan(text: n, style: style));
    //     return "";
    //   });
    // } on Exception catch (_) {
    //   return TextSpan(text: text, style: style);
    // }
    return TextSpan(children: children, style: style);
  }
}
