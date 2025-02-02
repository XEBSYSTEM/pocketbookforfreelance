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

class DrawStroke {
  final List<Offset> points;
  final DrawingMode mode;

  DrawStroke({
    required this.points,
    required this.mode,
  });

  bool get isEmpty => points.isEmpty;
  int get length => points.length;
  Offset operator [](int index) => points[index];

  // JSONシリアライズ
  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'mode': mode.toString(),
    };
  }

  // JSONデシリアライズ
  factory DrawStroke.fromJson(Map<String, dynamic> json) {
    return DrawStroke(
      points:
          (json['points'] as List).map((p) => Offset(p['x'], p['y'])).toList(),
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
  final List<DrawStroke> _strokes = [];
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
          final strokeData = jsonDecode(memoData['stroke_data'] as String);
          setState(() {
            _strokes.addAll(
              (strokeData as List).map((s) => DrawStroke.fromJson(s)),
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

  List<Offset>? _currentStroke;
  final GlobalKey _canvasKey = GlobalKey();
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();
  bool _isSaving = false;

  // 点と線分の距離を計算するヘルパーメソッド
  double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final double normalLength = math.sqrt(
        math.pow(lineEnd.dx - lineStart.dx, 2) +
            math.pow(lineEnd.dy - lineStart.dy, 2));

    if (normalLength == 0) return (point - lineStart).distance;

    final double t = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
            (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) /
        (normalLength * normalLength);

    if (t < 0) return (point - lineStart).distance;
    if (t > 1) return (point - lineEnd).distance;

    final nearestPoint = Offset(
      lineStart.dx + t * (lineEnd.dx - lineStart.dx),
      lineStart.dy + t * (lineEnd.dy - lineStart.dy),
    );

    return (point - nearestPoint).distance;
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
        onPanStart: (details) {
          setState(() {
            if (_currentMode == DrawingMode.eraser) {
              // 消しゴムモードの場合は現在のストロークは追加しない
              _currentStroke = [details.localPosition];
            } else {
              final points = [details.localPosition];
              final stroke = DrawStroke(
                points: points,
                mode: _currentMode,
              );
              _currentStroke = points;
              _strokes.add(stroke);
            }
          });
        },
        onPanUpdate: (details) {
          if (_currentMode == DrawingMode.eraser) {
            setState(() {
              final currentPoint = details.localPosition;
              final eraserRadius = 20.0;

              // 過去のストロークをチェック
              for (int i = 0; i < _strokes.length; i++) {
                final stroke = _strokes[i];
                if (stroke.mode == DrawingMode.eraser || stroke.isEmpty)
                  continue;

                // ストロークの各セグメントをチェック
                for (int j = 1; j < stroke.length; j++) {
                  final p1 = stroke[j - 1];
                  final p2 = stroke[j];

                  // 点と線分の距離を計算
                  final distance = _pointToLineDistance(currentPoint, p1, p2);
                  if (distance < eraserRadius) {
                    // 交差した場合、ストロークを削除
                    _strokes[i] = DrawStroke(points: [], mode: stroke.mode);
                    break;
                  }
                }
              }

              // 消しゴムの軌跡を更新
              _currentStroke?.add(details.localPosition);
            });
          } else {
            setState(() {
              _currentStroke?.add(details.localPosition);
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            _currentStroke = null;
          });
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
                painter: HandwritingPainter(_strokes),
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
                _strokes.clear();
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
    if (_strokes.isEmpty) {
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
      final strokeData = jsonEncode(_strokes.map((s) => s.toJson()).toList());

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
  final List<DrawStroke> strokes;
  final double strokeWidth = 3.0;

  HandwritingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.isEmpty || stroke.mode == DrawingMode.eraser) continue;

      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

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
