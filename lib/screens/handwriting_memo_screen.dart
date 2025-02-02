import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../db/handwriting_memo_repository.dart';
import 'dart:developer' as developer;

enum DrawingMode {
  pen,
  eraser,
}

class DrawPoint {
  final Offset position;
  final DrawingMode mode;
  final DateTime timestamp;
  final double strokeWidth;

  DrawPoint({
    required this.position,
    required this.mode,
    required this.strokeWidth,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'x': position.dx,
      'y': position.dy,
      'mode': mode.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'strokeWidth': strokeWidth,
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
    );
  }
}

class HandwritingMemoScreen extends StatefulWidget {
  final Uint8List? initialMemoData;
  final int? memoId;

  const HandwritingMemoScreen({
    super.key,
    this.initialMemoData,
    this.memoId,
  });

  @override
  State<HandwritingMemoScreen> createState() => _HandwritingMemoScreenState();
}

class _HandwritingMemoScreenState extends State<HandwritingMemoScreen> {
  final List<DrawPoint> _points = [];
  DrawingMode _currentMode = DrawingMode.pen;
  bool _isLoading = false;
  Offset? _eraserPosition;
  double _strokeWidth = 2.0;

  final List<double> _availableStrokeWidths = [1, 2, 4, 8, 16];

  @override
  void initState() {
    super.initState();
    if (widget.memoId != null) {
      _loadInitialMemoData();
    }
  }

  Future<void> _loadInitialMemoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = HandwritingMemoRepository();
      final memoData = await repository.getHandwritingMemo(widget.memoId!);

      if (memoData != null && memoData['stroke_data'] != null) {
        final pointData = jsonDecode(memoData['stroke_data'] as String);
        setState(() {
          _points.addAll(
            (pointData as List).map((p) => DrawPoint.fromJson(p)),
          );
        });
      }
    } catch (e) {
      developer.log('メモデータの読み込みに失敗しました: $e',
          name: 'HandwritingMemoScreen._loadInitialMemoData', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final GlobalKey _canvasKey = GlobalKey();
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();
  bool _isSaving = false;

  void _handleDrawing(Offset position) {
    setState(() {
      _eraserPosition = _currentMode == DrawingMode.eraser ? position : null;
    });

    if (_currentMode == DrawingMode.eraser) {
      setState(() {
        final double eraseRadius = _strokeWidth * 5;

        _points.removeWhere((point) {
          return (point.position - position).distance.toDouble() <= eraseRadius;
        });

        for (int i = _points.length - 1; i > 0; i--) {
          if (i >= _points.length) continue;

          final p1 = _points[i - 1].position;
          final p2 = _points[i].position;

          final distance = _getDistanceToLineSegment(position, p1, p2);

          if (distance <= eraseRadius) {
            _points.removeAt(i);
            _points.removeAt(i - 1);
            i--;
          }
        }
      });
    } else {
      setState(() {
        _points.add(DrawPoint(
          position: position,
          mode: _currentMode,
          strokeWidth: _strokeWidth,
        ));
      });
    }
  }

  double _getDistanceToLineSegment(Offset p, Offset start, Offset end) {
    final a = p - start;
    final b = end - start;
    final bLen = b.distance.toDouble();

    if (bLen == 0) return a.distance.toDouble();

    final t = math.max(
        0.0,
        math.min(
            1.0, ((a.dx * b.dx + a.dy * b.dy) / (bLen * bLen)).toDouble()));
    final projection = start + (b * t);

    return (p - projection).distance.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('手書きメモ'),
      ),
      body: GestureDetector(
        onTapDown: (details) => _handleDrawing(details.localPosition),
        onPanStart: (details) => _handleDrawing(details.localPosition),
        onPanUpdate: (details) => _handleDrawing(details.localPosition),
        onPanEnd: (details) {
          setState(() {
            _eraserPosition = null;
          });
        },
        child: RepaintBoundary(
          key: _canvasKey,
          child: CustomPaint(
            painter: HandwritingPainter(
              _points,
              eraserPosition: _eraserPosition,
              eraserWidth: _strokeWidth,
            ),
            size: Size.infinite,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ..._availableStrokeWidths.map((width) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _strokeWidth = width;
                  });
                },
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _strokeWidth == width ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: width,
                      height: width,
                      decoration: BoxDecoration(
                        color: _currentMode == DrawingMode.pen
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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'eraser',
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == DrawingMode.eraser
                    ? DrawingMode.pen
                    : DrawingMode.eraser;
                _eraserPosition = null;
              });
            },
            child: Icon(
              _currentMode == DrawingMode.eraser
                  ? Icons.edit
                  : Icons.auto_fix_normal,
            ),
            backgroundColor:
                _currentMode == DrawingMode.eraser ? Colors.red : null,
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'clear',
            onPressed: () {
              setState(() {
                _points.clear();
              });
            },
            child: const Icon(Icons.clear),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'save',
            onPressed: _isSaving ? null : _saveHandwritingMemo,
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Future<void> _saveHandwritingMemo() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メモを書いてください')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('イメージの変換に失敗しました');
      }

      final Uint8List memoData = byteData.buffer.asUint8List();

      final double scale = 0.2;
      final ui.Image thumbnailImage = await boundary.toImage(pixelRatio: scale);
      final ByteData? thumbnailByteData =
          await thumbnailImage.toByteData(format: ui.ImageByteFormat.png);

      if (thumbnailByteData == null) {
        throw Exception('サムネイルの生成に失敗しました');
      }

      final Uint8List thumbnailData = thumbnailByteData.buffer.asUint8List();
      final strokeData = jsonEncode(_points.map((p) => p.toJson()).toList());

      if (widget.memoId != null) {
        await _repository.updateHandwritingMemo(
          widget.memoId!,
          memoData,
          thumbnailData,
          strokeData,
        );
      } else {
        await _repository.insertHandwritingMemo(
          memoData,
          thumbnailData,
          strokeData,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メモを保存しました')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      developer.log('メモの保存中にエラーが発生しました: $e',
          name: 'HandwritingMemoScreen._saveHandwritingMemo',
          error: e,
          stackTrace: StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

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
