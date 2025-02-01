import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MemoTab extends StatefulWidget {
  const MemoTab({super.key});

  @override
  State<MemoTab> createState() => _MemoTabState();
}

class _MemoTabState extends State<MemoTab> {
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _currentStroke = [details.localPosition];
            _strokes.add(_currentStroke!);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _currentStroke?.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _currentStroke = null;
          });
        },
        child: CustomPaint(
          painter: HandwritingPainter(_strokes),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _strokes.clear();
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  HandwritingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) => true;
}
