import 'package:flutter/material.dart';

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double padding;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 2,
    this.gap = 5,
    this.padding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    double x = padding, y = padding;

    size = Size(size.width - padding * 2, size.height - padding * 2);

    while (x < size.width) {
      path.moveTo(x + padding, padding);
      path.lineTo(x + gap + padding, padding);
      x += gap * 2;
    }
    while (y < size.height) {
      path.moveTo(size.width + padding, y + padding);
      path.lineTo(size.width + padding, y + gap + padding);
      y += gap * 2;
    }
    x = size.width;
    while (x > 0) {
      path.moveTo(x + padding, size.height + padding);
      path.lineTo(x - gap + padding, size.height + padding);
      x -= gap * 2;
    }
    y = size.height;
    while (y > 0) {
      path.moveTo(padding, y + padding);
      path.lineTo(padding, y - gap + padding);
      y -= gap * 2;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
