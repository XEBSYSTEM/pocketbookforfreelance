import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';
import 'dart:developer' as developer;

class HandwritingMemoRepository {
  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  Future<int> insertHandwritingMemo(
      Uint8List memoData, Uint8List thumbnailData, String strokeData) async {
    try {
      developer.log('手書きメモの保存を開始します',
          name: 'HandwritingMemoRepository.insertHandwritingMemo');
      developer.log('サムネイルサイズ: ${thumbnailData.length} bytes',
          name: 'HandwritingMemoRepository.insertHandwritingMemo');

      final db = await database;
      final result = await db.insert(
        'handwriting_memos',
        {
          'memo_data': memoData,
          'thumbnail_data': thumbnailData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'stroke_data': strokeData,
        },
      );

      developer.log('手書きメモの保存が完了しました: ID=$result',
          name: 'HandwritingMemoRepository.insertHandwritingMemo');
      return result;
    } catch (e) {
      developer.log('手書きメモの保存中にエラーが発生しました: $e',
          name: 'HandwritingMemoRepository.insertHandwritingMemo', error: e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllHandwritingMemos() async {
    final db = await database;
    return await db.query('handwriting_memos', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getHandwritingMemo(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'handwriting_memos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }
    return result.first;
  }

  Future<int> updateHandwritingMemo(int id, Uint8List memoData,
      Uint8List thumbnailData, String strokeData) async {
    try {
      developer.log('手書きメモの更新を開始します: ID=$id',
          name: 'HandwritingMemoRepository.updateHandwritingMemo');
      developer.log('サムネイルサイズ: ${thumbnailData.length} bytes',
          name: 'HandwritingMemoRepository.updateHandwritingMemo');

      final db = await database;
      final result = await db.update(
        'handwriting_memos',
        {
          'memo_data': memoData,
          'thumbnail_data': thumbnailData,
          'updated_at': DateTime.now().toIso8601String(),
          'stroke_data': strokeData,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      developer.log('手書きメモの更新が完了しました: ID=$id, 更新件数=$result',
          name: 'HandwritingMemoRepository.updateHandwritingMemo');
      return result;
    } catch (e) {
      developer.log('手書きメモの更新中にエラーが発生しました: ID=$id, エラー=$e',
          name: 'HandwritingMemoRepository.updateHandwritingMemo', error: e);
      rethrow;
    }
  }

  Future<int> deleteHandwritingMemo(int id) async {
    final db = await database;
    return await db.delete(
      'handwriting_memos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
