import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class StrokeControlBar extends StatelessWidget {
  final List<double> availableStrokeWidths;
  final double currentStrokeWidth;
  final DrawingMode currentMode;
  final ValueChanged<double> onStrokeWidthChanged;

  const StrokeControlBar({
    super.key,
    required this.availableStrokeWidths,
    required this.currentStrokeWidth,
    required this.currentMode,
    required this.onStrokeWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...availableStrokeWidths.map((width) {
                return IconButton(
                  onPressed: () => onStrokeWidthChanged(width),
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentStrokeWidth == width
                            ? Colors.blue
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: width,
                        height: width,
                        decoration: BoxDecoration(
                          color: currentMode == DrawingMode.pen
                              ? Colors.black
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
