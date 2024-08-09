import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

const shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

Color randColor() {
  return Color((math.Random().nextDouble() * 0xFFFFFF).toInt());
}

List<Color> generateRandomColors(int count) {
  Random random = Random();
  List<Color> colors = [];

  for (int i = 0; i < count; i++) {
    // Generate a color with a random hue and full saturation and lightness
    double hue = (360 / count) * i + random.nextInt(360 ~/ count);
    HSLColor hslColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5);
    colors.add(hslColor.toColor());
  }

  return colors;
}

class ColorsConstants {
  static final List<ColorsPair> randColors = [
    ColorsPair(
        backgroundColor: const Color(0xFF6200ee),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFF03dac5),
        fontColor: const Color(0xFF050301)),
    ColorsPair(
        backgroundColor: const Color(0xFF344955),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFFf9aa33),
        fontColor: const Color(0xFF050301)),
    ColorsPair(
        backgroundColor: const Color(0xFF0336ff),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFFf4511e),
        fontColor: const Color(0xFF050301)),
    ColorsPair(
        backgroundColor: const Color(0xFF5d1049),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFFe30425),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFFfedbd0),
        fontColor: const Color(0xFF050301)),
    ColorsPair(
        backgroundColor: const Color(0xFF232f34),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFF3700b3),
        fontColor: const Color(0xFFFFFFFF)),
    ColorsPair(
        backgroundColor: const Color(0xFFe52165),
        fontColor: const Color(0xFF0d1137)),
    ColorsPair(
        backgroundColor: const Color(0xFFd72631),
        fontColor: const Color(0xFFa2d5c6)),
    ColorsPair(
        backgroundColor: const Color(0xFF077b8a),
        fontColor: const Color(0xFF5c3c92)),
    ColorsPair(
        backgroundColor: const Color(0xFFe2d810),
        fontColor: const Color(0xFFd9138a)),
    ColorsPair(
        backgroundColor: const Color(0xFF12a4d9),
        fontColor: const Color(0xFF322e2f)),
    ColorsPair(
        backgroundColor: const Color(0xFFf3ca20),
        fontColor: const Color(0xFF000000)),
    ColorsPair(
        backgroundColor: const Color(0xFFcf1578),
        fontColor: const Color(0xFFe8d21d)),
    ColorsPair(
        backgroundColor: const Color(0xFF039fbe),
        fontColor: const Color(0xFFb20238)),
    ColorsPair(
        backgroundColor: const Color(0xFFe75874),
        fontColor: const Color(0xFFbe1558)),
    ColorsPair(
        backgroundColor: const Color(0xFFfbcbc9),
        fontColor: const Color(0xFF322514)),
    ColorsPair(
        backgroundColor: const Color(0xFFef9d10),
        fontColor: const Color(0xFF3b4d61)),
    ColorsPair(
        backgroundColor: const Color(0xFF6b7b8c),
        fontColor: const Color(0xFF1e3d59)),
    ColorsPair(
        backgroundColor: const Color(0xFFf5f0e1),
        fontColor: const Color(0xFFff6e40)),
    ColorsPair(
        backgroundColor: const Color(0xFFffc13b),
        fontColor: const Color(0xFFecc19c)),
    ColorsPair(
        backgroundColor: const Color(0xFF1e847f),
        fontColor: const Color(0xFF000000)),
    ColorsPair(
        backgroundColor: const Color(0xFF26495c),
        fontColor: const Color(0xFFc4a35a)),
    ColorsPair(
        backgroundColor: const Color(0xFFc66b3d),
        fontColor: const Color(0xFFe5e5dc)),
    ColorsPair(
        backgroundColor: const Color(0xFFd9a5b3),
        fontColor: const Color(0xFF1868ae)),
    ColorsPair(
        backgroundColor: const Color(0xFFc6d7eb),
        fontColor: const Color(0xFF408ec6)),
    ColorsPair(
        backgroundColor: const Color(0xFF7a2048),
        fontColor: const Color(0xFF1e2761)),
    ColorsPair(
        backgroundColor: const Color(0xFF8a307f),
        fontColor: const Color(0xFF79a7d3)),
    ColorsPair(
        backgroundColor: const Color(0xFF6883bc),
        fontColor: const Color(0xFF1d3c45)),
    ColorsPair(
        backgroundColor: const Color(0xFFd2601a),
        fontColor: const Color(0xFFfff1e1)),
    ColorsPair(
        backgroundColor: const Color(0xFFaed6dc),
        fontColor: const Color(0xFFff9a8d)),
    ColorsPair(
        backgroundColor: const Color(0xFF4a536b),
        fontColor: const Color(0xFFda68a0)),
    ColorsPair(
        backgroundColor: const Color(0xFF77c593),
        fontColor: const Color(0xFFed3572)),
    ColorsPair(
        backgroundColor: const Color(0xFF316879),
        fontColor: const Color(0xFFf47a60)),
    ColorsPair(
        backgroundColor: const Color(0xFF7fe7dc),
        fontColor: const Color(0xFFced7d8)),
    ColorsPair(
        backgroundColor: const Color(0xFFd902ee),
        fontColor: const Color(0xFFffd79d)),
    ColorsPair(
        backgroundColor: const Color(0xFFf162ff),
        fontColor: const Color(0xFF320d3e)),
    ColorsPair(
        backgroundColor: const Color(0xFFffcce7),
        fontColor: const Color(0xFFdaf2dc)),
    ColorsPair(
        backgroundColor: const Color(0xFF81b7d2),
        fontColor: const Color(0xFF4d5198)),
    ColorsPair(
        backgroundColor: const Color(0xFFddc3a5),
        fontColor: const Color(0xFF201e20)),
    ColorsPair(
        backgroundColor: const Color(0xFFe0a96d),
        fontColor: const Color(0xFFedca82)),
    ColorsPair(
        backgroundColor: const Color(0xFF097770),
        fontColor: const Color(0xFFe0cdbe)),
    ColorsPair(
        backgroundColor: const Color(0xFFa9c0a6),
        fontColor: const Color(0xFFe1dd72)),
    ColorsPair(
        backgroundColor: const Color(0xFFa8c66c),
        fontColor: const Color(0xFF1b6535)),
    ColorsPair(
        backgroundColor: const Color(0xFFd13ca4),
        fontColor: const Color(0xFFffea04)),
    ColorsPair(
        backgroundColor: const Color(0xFFfe3a9e),
        fontColor: const Color(0xFFe3b448)),
    ColorsPair(
        backgroundColor: const Color(0xFFcbd18f),
        fontColor: const Color(0xFF3a6b35)),
    ColorsPair(
        backgroundColor: const Color(0xFFf6ead4),
        fontColor: const Color(0xFFa2a595)),
    ColorsPair(
        backgroundColor: const Color(0xFFb4a284),
        fontColor: const Color(0xFF79cbb8)),
    ColorsPair(
        backgroundColor: const Color(0xFF500472),
        fontColor: const Color(0xFFf5beb4)),
    ColorsPair(
        backgroundColor: const Color(0xFF9bc472),
        fontColor: const Color(0xFFcbf6db)),
    ColorsPair(
        backgroundColor: const Color(0xFFb85042),
        fontColor: const Color(0xFFe7e8d1)),
    ColorsPair(
        backgroundColor: const Color(0xFFa7beae),
        fontColor: const Color(0xFFd71b3b)),
    ColorsPair(
        backgroundColor: const Color(0xFFe8d71e),
        fontColor: const Color(0xFF16acea)),
    ColorsPair(
        backgroundColor: const Color(0xFF4203c9),
        fontColor: const Color(0xFF829079)),
    ColorsPair(
        backgroundColor: const Color(0xFFede6b9),
        fontColor: const Color(0xFFb9925e)),
    ColorsPair(
        backgroundColor: const Color(0xFF1fbfb8),
        fontColor: const Color(0xFF05716c)),
    ColorsPair(
        backgroundColor: const Color(0xFF1978a5),
        fontColor: const Color(0xFF031163)),
    ColorsPair(
        backgroundColor: const Color(0xFF7fc3c0),
        fontColor: const Color(0xFFcfb845)),
    ColorsPair(
        backgroundColor: const Color(0xFF141414),
        fontColor: const Color(0xFFefb5a3)),
    ColorsPair(
        backgroundColor: const Color(0xFFf57e7e),
        fontColor: const Color(0xFF315f72)),
  ];
  static ColorsPair getColorsPair(int index) {
    if (index >= randColors.length) {
      return ColorsPair(backgroundColor: randColor(), fontColor: randColor());
    }
    return randColors[index];
  }
}

class ColorsPair {
  final Color backgroundColor;
  final Color fontColor;

  ColorsPair({required this.backgroundColor, required this.fontColor});
}
