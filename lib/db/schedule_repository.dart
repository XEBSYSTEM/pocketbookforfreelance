import 'package:sqflite/sqflite.dart';
import '../models/schedule_form_data.dart';

class ScheduleRepository {
  final Database db;

  ScheduleRepository(this.db);

  // スケジュールの作成
  Future<int> createSchedule(Map<String, dynamic> schedule) async {
    try {
      // ScheduleFormDataを使用してデータを変換
      final formData = ScheduleFormData.fromMap(schedule);
      final mappedData = formData.toMap();

      if (mappedData['date'] == null) {
        throw Exception('日付が指定されていません');
      }

      // DateTimeをYYYY-MM-DD形式の文字列に変換
      final dateStr =
          (mappedData['date'] as DateTime).toIso8601String().split('T')[0];

      final data = {
        'title': mappedData['title'],
        'date': dateStr,
        'is_all_day': mappedData['isAllDay'] ? 1 : 0,
        'start_time': mappedData['startTime'],
        'end_time': mappedData['endTime'],
        'meeting_type': mappedData['meetingType'],
        'url': mappedData['url'],
        'agent_id': mappedData['agent'],
        'end_company_id': mappedData['endCompany'],
        'memo': mappedData['memo'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await db.insert('schedules', data);
    } catch (e) {
      print('Error creating schedule: $e');
      throw Exception('スケジュールの登録に失敗しました: $e');
    }
  }

  // スケジュールの取得（日付指定）
  Future<List<Map<String, dynamic>>> readSchedulesByDate(DateTime date) async {
    final dateStr = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];
    final nextDateStr = DateTime(date.year, date.month, date.day + 1)
        .toIso8601String()
        .split('T')[0];

    return await db.query(
      'schedules',
      where: 'date >= ? AND date < ?',
      whereArgs: [dateStr, nextDateStr],
      orderBy: 'start_time ASC',
    );
  }

  // スケジュールの取得（1件）
  Future<Map<String, dynamic>?> readSchedule(int id) async {
    final maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // スケジュールの更新
  Future<int> updateSchedule(int id, Map<String, dynamic> schedule) async {
    try {
      // ScheduleFormDataを使用してデータを変換
      final formData = ScheduleFormData.fromMap(schedule);
      final mappedData = formData.toMap();

      if (mappedData['date'] == null) {
        throw Exception('日付が指定されていません');
      }

      // DateTimeをYYYY-MM-DD形式の文字列に変換
      final dateStr =
          (mappedData['date'] as DateTime).toIso8601String().split('T')[0];

      final data = {
        'title': mappedData['title'],
        'date': dateStr,
        'is_all_day': mappedData['isAllDay'] ? 1 : 0,
        'start_time': mappedData['startTime'],
        'end_time': mappedData['endTime'],
        'meeting_type': mappedData['meetingType'],
        'url': mappedData['url'],
        'agent_id': mappedData['agent'],
        'end_company_id': mappedData['endCompany'],
        'memo': mappedData['memo'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await db.update(
        'schedules',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating schedule: $e');
      throw Exception('スケジュールの更新に失敗しました: $e');
    }
  }

  // スケジュールの削除
  Future<int> deleteSchedule(int id) async {
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
