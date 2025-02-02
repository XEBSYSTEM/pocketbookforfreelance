import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class StrokeControlBar extends StatelessWidget {
  final List<double> availableStrokeWidths;
  final double currentStrokeWidth;
  final DrawingMode currentMode;
  final Color currentColor;
  final ValueChanged<double> onStrokeWidthChanged;
  final ValueChanged<Color> onColorChanged;

  static const List<Color> availableColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.brown,
  ];

  const StrokeControlBar({
    super.key,
    required this.availableStrokeWidths,
    required this.currentStrokeWidth,
    required this.currentMode,
    required this.currentColor,
    required this.onStrokeWidthChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('色を選択'),
                      content: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              onColorChanged(color);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: currentColor == color
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
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
                              ? currentColor
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
