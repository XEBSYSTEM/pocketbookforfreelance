import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../db/handwriting_memo_repository.dart';
import 'dart:developer' as developer;

class HandwritingMemoScreen extends StatefulWidget {
  const HandwritingMemoScreen({super.key});

  @override
  State<HandwritingMemoScreen> createState() => _HandwritingMemoScreenState();
}

class _HandwritingMemoScreenState extends State<HandwritingMemoScreen> {
  final List<List<Offset>> _strokes = [];
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
        child: RepaintBoundary(
          key: _canvasKey,
          child: CustomPaint(
            painter: HandwritingPainter(_strokes),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
      await _repository.insertHandwritingMemo(memoData, thumbnailData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メモを保存しました')),
        );
        setState(() {
          _strokes.clear();
        });
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
