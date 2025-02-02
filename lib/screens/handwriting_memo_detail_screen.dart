import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'handwriting_memo_screen.dart';
import '../db/handwriting_memo_repository.dart';

class HandwritingMemoDetailScreen extends StatefulWidget {
  final Uint8List memoData;
  final DateTime createdAt;
  final int memoId;

  const HandwritingMemoDetailScreen({
    Key? key,
    required this.memoData,
    required this.createdAt,
    required this.memoId,
  }) : super(key: key);

  @override
  State<HandwritingMemoDetailScreen> createState() =>
      _HandwritingMemoDetailScreenState();
}

class _HandwritingMemoDetailScreenState
    extends State<HandwritingMemoDetailScreen> {
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();

  Future<void> _showDeleteConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('メモの削除'),
          content: const Text('このメモを削除してもよろしいですか？\nこの操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.deleteHandwritingMemo(widget.memoId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メモを削除しました')),
          );
          Navigator.of(context).pop(true); // 削除後に前の画面に戻る
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('メモの削除に失敗しました: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.createdAt.toLocal().toString().split('.')[0]),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HandwritingMemoScreen(
                    initialMemoData: widget.memoData,
                    memoId: widget.memoId,
                  ),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true); // 編集が完了したら前の画面に戻る
              }
            },
            icon: const Icon(Icons.edit),
            tooltip: '編集',
          ),
          IconButton(
            onPressed: _showDeleteConfirmationDialog,
            icon: const Icon(Icons.delete),
            tooltip: '削除',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4.0,
          child: Image.memory(widget.memoData),
        ),
      ),
    );
  }
}
