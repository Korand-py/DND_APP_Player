import 'dart:math';

import 'package:flutter/material.dart';

/// Минималистичный контур кубика: заливка surface1, обводка accentLine.
/// Никаких градиентов и толстых рамок.
class DicePainter extends CustomPainter {
  const DicePainter({
    required this.sides,
    this.fill = const Color(0xFF09090B),
    this.stroke = const Color(0x669880FF),
    this.strokeWidth = 1.5,
  });

  final int sides;
  final Color fill;
  final Color stroke;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildPath(size);

    final Paint fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  Path _buildPath(Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.shortestSide / 2 - strokeWidth;
    final Path path = Path();

    switch (sides) {
      case 4:
        _polygon(path, cx, cy, r, 3);
      case 6:
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: r * 1.62,
              height: r * 1.62,
            ),
            const Radius.circular(16),
          ),
        );
      case 8:
        path
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.78, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.78, cy)
          ..close();
      case 10:
        path
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.62, cy + r * 0.38)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.62, cy + r * 0.38)
          ..close();
      case 12:
        _polygon(path, cx, cy, r, 5);
      case 20:
        _polygon(path, cx, cy, r, 6);
      default:
        path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    }

    return path;
  }

  void _polygon(Path path, double cx, double cy, double r, int corners) {
    for (int i = 0; i < corners; i++) {
      final double angle = 2 * pi * i / corners - pi / 2;
      final double x = cx + r * cos(angle);
      final double y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) {
    return oldDelegate.sides != sides ||
        oldDelegate.fill != fill ||
        oldDelegate.stroke != stroke ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
