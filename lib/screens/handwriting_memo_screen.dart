import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../db/handwriting_memo_repository.dart';
import '../models/drawing_point.dart';
import '../widgets/handwriting_painter.dart';
import '../widgets/stroke_control_bar.dart';
import 'dart:developer' as developer;

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
  final GlobalKey _canvasKey = GlobalKey();
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();
  bool _isSaving = false;

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
            size: MediaQuery.of(context).size,
          ),
        ),
      ),
      bottomNavigationBar: StrokeControlBar(
        availableStrokeWidths: _availableStrokeWidths,
        currentStrokeWidth: _strokeWidth,
        currentMode: _currentMode,
        onStrokeWidthChanged: (width) {
          setState(() {
            _strokeWidth = width;
          });
        },
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
}
