import 'package:flutter/material.dart';

enum DrawingMode {
  pen,
  eraser,
}

class DrawPoint {
  final Offset position;
  final DrawingMode mode;
  final DateTime timestamp;
  final double strokeWidth;
  final Color color;

  DrawPoint({
    required this.position,
    required this.mode,
    required this.strokeWidth,
    this.color = Colors.black,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'x': position.dx,
      'y': position.dy,
      'mode': mode.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'strokeWidth': strokeWidth,
      'color': color.value,
    };
  }

  factory DrawPoint.fromJson(Map<String, dynamic> json) {
    return DrawPoint(
      position: Offset(json['x'] as double, json['y'] as double),
      mode: DrawingMode.values.firstWhere(
        (e) => e.toString() == json['mode'],
        orElse: () => DrawingMode.pen,
      ),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      color: Color(json['color'] as int),
    );
  }
}
