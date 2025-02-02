import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../db/handwriting_memo_repository.dart';
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

enum DrawingMode {
  pen,
  eraser,
}

class _HandwritingMemoScreenState extends State<HandwritingMemoScreen> {
  final List<List<Offset>> _strokes = [];
  late Image? _backgroundImage;
  DrawingMode _currentMode = DrawingMode.pen;

  @override
  void initState() {
    super.initState();
    if (widget.initialMemoData != null) {
      _backgroundImage = Image.memory(widget.initialMemoData!);
    } else {
      _backgroundImage = null;
    }
  }

  List<Offset>? _currentStroke;
  final GlobalKey _canvasKey = GlobalKey();
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手書きメモ'),
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            if (_currentMode == DrawingMode.eraser) {
              // 消しゴムモードの場合、同じ位置に始点と終点を設定
              _currentStroke = [details.localPosition, details.localPosition];
            } else {
              _currentStroke = [details.localPosition];
            }
            _strokes.add(_currentStroke!);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            if (_currentMode == DrawingMode.eraser) {
              // 消しゴムモードの場合、最後の点を更新
              if (_currentStroke != null && _currentStroke!.length >= 2) {
                _currentStroke![1] = details.localPosition;
              }
            } else {
              _currentStroke?.add(details.localPosition);
            }
          });
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

      // データベースに保存
      if (widget.memoId != null) {
        // 既存メモの更新
        await _repository.updateHandwritingMemo(
          widget.memoId!,
          memoData,
          thumbnailData,
        );
      } else {
        // 新規メモの保存
        await _repository.insertHandwritingMemo(memoData, thumbnailData);
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
  final List<List<Offset>> strokes;
  final double strokeWidth = 3.0;
  final double eraserWidth = 20.0;

  HandwritingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // 最後のストロークが消しゴムの場合、他のストロークと交差するか確認
      if (i == strokes.length - 1 &&
          stroke.isNotEmpty &&
          stroke.first == stroke.last) {
        paint.color = Colors.transparent;
        paint.strokeWidth = eraserWidth;

        // 消しゴムの範囲を計算
        final eraserPath = Path();
        for (int j = 0; j < stroke.length; j++) {
          if (j == 0) {
            eraserPath.moveTo(stroke[j].dx, stroke[j].dy);
          } else {
            eraserPath.lineTo(stroke[j].dx, stroke[j].dy);
          }
        }

        // 他のストロークと交差するか確認し、交差する部分を削除
        for (int j = strokes.length - 2; j >= 0; j--) {
          final targetStroke = strokes[j];
          if (targetStroke.isEmpty) continue;

          final targetPath = Path();
          targetPath.moveTo(targetStroke[0].dx, targetStroke[0].dy);
          for (int k = 1; k < targetStroke.length; k++) {
            targetPath.lineTo(targetStroke[k].dx, targetStroke[k].dy);
          }

          // パスが交差するか確認
          final bounds = eraserPath.getBounds();
          final targetBounds = targetPath.getBounds();
          if (bounds.overlaps(targetBounds)) {
            strokes[j] = [];
          }
        }
      } else {
        // 通常のペンストローク
        paint.color = Colors.black;
        paint.strokeWidth = strokeWidth;

        if (stroke.isEmpty) continue;

        final path = Path();
        path.moveTo(stroke[0].dx, stroke[0].dy);
        for (int j = 1; j < stroke.length; j++) {
          path.lineTo(stroke[j].dx, stroke[j].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) => true;
}
