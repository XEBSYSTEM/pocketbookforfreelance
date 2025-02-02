import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class HandwritingPainter extends CustomPainter {
  final List<DrawPoint> points;
  final Offset? eraserPosition;
  final double eraserWidth;
  static const interpolationTimeThreshold = Duration(milliseconds: 100);

  HandwritingPainter(
    this.points, {
    this.eraserPosition,
    this.eraserWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (eraserPosition != null) {
      final eraseRadius = eraserWidth * 5.0;
      final eraserPaint = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(eraserPosition!, eraseRadius, eraserPaint);
    }

    if (points.isEmpty) return;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      if (next.timestamp.difference(current.timestamp) <=
          interpolationTimeThreshold) {
        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = current.strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawLine(current.position, next.position, paint);
      }
    }

    for (final point in points) {
      final paint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point.position, point.strokeWidth / 2, paint);
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) => true;
}
