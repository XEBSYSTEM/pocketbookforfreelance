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

  DrawPoint({
    required this.position,
    required this.mode,
  });

  // JSONシリアライズ
  Map<String, dynamic> toJson() {
    return {
      'x': position.dx,
      'y': position.dy,
      'mode': mode.toString(),
    };
  }

  // JSONデシリアライズ
  factory DrawPoint.fromJson(Map<String, dynamic> json) {
    return DrawPoint(
      position: Offset(json['x'] as double, json['y'] as double),
      mode: DrawingMode.values.firstWhere(
        (e) => e.toString() == json['mode'],
        orElse: () => DrawingMode.pen,
      ),
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
  late Image? _backgroundImage;
  DrawingMode _currentMode = DrawingMode.pen;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMemoData != null) {
      _loadInitialMemoData();
    } else {
      _backgroundImage = null;
      _isImageLoaded = true;
    }
  }

  Future<void> _loadInitialMemoData() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.initialMemoData!);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // 画像データをバイトデータに変換
      final byteData = await image.toByteData();
      if (byteData == null) return;

      final repository = HandwritingMemoRepository();
      if (widget.memoId != null) {
        final memoData = await repository.getHandwritingMemo(widget.memoId!);
        if (memoData != null && memoData['stroke_data'] != null) {
          final pointData = jsonDecode(memoData['stroke_data'] as String);
          setState(() {
            _points.addAll(
              (pointData as List).map((p) => DrawPoint.fromJson(p)),
            );
          });
        }
      }

      setState(() {
        _backgroundImage = Image.memory(widget.initialMemoData!);
        _isImageLoaded = true;
      });
    } catch (e) {
      developer.log('初期メモデータの読み込みに失敗しました: $e',
          name: 'HandwritingMemoScreen._loadInitialMemoData', error: e);
    }
  }

  final GlobalKey _canvasKey = GlobalKey();
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();
  bool _isSaving = false;

  void _handleDrawing(Offset position) {
    if (_currentMode == DrawingMode.eraser) {
      // 消しゴムモードの場合、近くの点を削除
      const double eraseRadius = 10.0;
      _points.removeWhere(
          (point) => (point.position - position).distance <= eraseRadius);
    } else {
      // ペンモードの場合、新しい点を追加
      setState(() {
        _points.add(DrawPoint(
          position: position,
          mode: _currentMode,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isImageLoaded) {
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
        onTapDown: (details) {
          _handleDrawing(details.localPosition);
        },
        onPanStart: (details) {
          _handleDrawing(details.localPosition);
        },
        onPanUpdate: (details) {
          _handleDrawing(details.localPosition);
        },
        child: Stack(
          children: [
            if (_backgroundImage != null)
              Positioned.fill(
                child: _backgroundImage!,
              ),
            RepaintBoundary(
              key: _canvasKey,
              child: CustomPaint(
                painter: HandwritingPainter(_points),
                size: Size.infinite,
              ),
            ),
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
      // キャンバスをイメージに変換
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('イメージの変換に失敗しました');
      }

      final Uint8List memoData = byteData.buffer.asUint8List();

      // サムネイルの生成（元のイメージを縮小）
      final double scale = 0.2; // サムネイルのサイズを20%に
      developer.log(
          'サムネイル生成を開始します - 元画像サイズ: ${image.width}x${image.height}, スケール: $scale',
          name: 'HandwritingMemoScreen._saveHandwritingMemo');
      final ui.Image thumbnailImage = await boundary.toImage(pixelRatio: scale);
      developer.log(
          'サムネイル画像を生成しました - サイズ: ${thumbnailImage.width}x${thumbnailImage.height}, メモリサイズ: ${thumbnailImage.height * thumbnailImage.width * 4}bytes',
          name: 'HandwritingMemoScreen._saveHandwritingMemo');

      final ByteData? thumbnailByteData =
          await thumbnailImage.toByteData(format: ui.ImageByteFormat.png);

      if (thumbnailByteData == null) {
        throw Exception('サムネイルの生成に失敗しました');
      }

      final Uint8List thumbnailData = thumbnailByteData.buffer.asUint8List();
      developer.log(
          'サムネイルデータを生成しました - PNG圧縮後のサイズ: ${thumbnailData.length}bytes, 圧縮率: ${(thumbnailData.length / (thumbnailImage.height * thumbnailImage.width * 4) * 100).toStringAsFixed(2)}%',
          name: 'HandwritingMemoScreen._saveHandwritingMemo');

      // ストロークデータをJSONに変換
      final strokeData = jsonEncode(_points.map((p) => p.toJson()).toList());

      // データベースに保存
      if (widget.memoId != null) {
        // 既存メモの更新
        await _repository.updateHandwritingMemo(
          widget.memoId!,
          memoData,
          thumbnailData,
          strokeData,
        );
      } else {
        // 新規メモの保存
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
        print(e.toString());
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
  final double pointSize = 2.0;

  HandwritingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = pointSize * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point.position, pointSize, paint);
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) => true;
}
