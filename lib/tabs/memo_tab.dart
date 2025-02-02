import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/handwriting_memo_screen.dart';
import '../screens/handwriting_memo_detail_screen.dart';
import '../db/handwriting_memo_repository.dart';

class MemoTab extends StatefulWidget {
  const MemoTab({super.key});

  @override
  State<MemoTab> createState() => _MemoTabState();
}

class _MemoTabState extends State<MemoTab> {
  final HandwritingMemoRepository _repository = HandwritingMemoRepository();
  List<Map<String, dynamic>> _memos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final memos = await _repository.getAllHandwritingMemos();
      setState(() {
        _memos = memos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('メモの読み込みに失敗しました: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memos.isEmpty
              ? const Center(child: Text('メモがありません'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _memos.length,
                  itemBuilder: (context, index) {
                    final memo = _memos[index];
                    final thumbnailData = memo['thumbnail_data'] as Uint8List;
                    final createdAt =
                        DateTime.parse(memo['created_at'] as String);

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          final memoDetails =
                              await _repository.getHandwritingMemo(memo['id']);
                          if (memoDetails != null && mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HandwritingMemoDetailScreen(
                                  memoData: memoDetails['memo_data'],
                                  createdAt:
                                      DateTime.parse(memoDetails['created_at']),
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.memory(
                                thumbnailData,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                createdAt.toLocal().toString().split('.')[0],
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HandwritingMemoScreen(),
            ),
          );
          // 画面に戻ってきたときにメモを再読み込み
          _loadMemos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
