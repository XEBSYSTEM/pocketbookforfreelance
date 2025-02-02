import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';

class HandwritingMemoRepository {
  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  Future<int> insertHandwritingMemo(
      Uint8List memoData, Uint8List thumbnailData) async {
    final db = await database;
    return await db.insert(
      'handwriting_memos',
      {
        'memo_data': memoData,
        'thumbnail_data': thumbnailData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
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

  Future<int> updateHandwritingMemo(
      int id, Uint8List memoData, Uint8List thumbnailData) async {
    final db = await database;
    return await db.update(
      'handwriting_memos',
      {
        'memo_data': memoData,
        'thumbnail_data': thumbnailData,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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
