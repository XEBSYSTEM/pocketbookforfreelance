import 'package:flutter/material.dart';

class ScheduleFormData {
  String title;
  DateTime? date;
  bool isAllDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? meetingType;
  String? url;
  String? agentId;
  String? endCompanyId;
  String? memo;

  ScheduleFormData({
    this.title = '',
    this.date,
    this.isAllDay = false,
    this.startTime,
    this.endTime,
    this.meetingType,
    this.url = '',
    this.agentId,
    this.endCompanyId,
    this.memo = '',
  });

  // 文字列からTimeOfDayを作成するヘルパーメソッド
  static TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;

    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  // 入力データからインスタンスを作成
  factory ScheduleFormData.fromMap(Map<String, dynamic> data) {
    String? startTimeStr = data['startTime']?.toString();
    String? endTimeStr = data['endTime']?.toString();

    return ScheduleFormData(
      title: data['title'] ?? '',
      date: data['date'],
      isAllDay: data['isAllDay'] ?? false,
      startTime: _parseTimeString(startTimeStr),
      endTime: _parseTimeString(endTimeStr),
      meetingType: data['meetingType'],
      url: data['url'] ?? '',
      agentId: data['agent']?.toString(),
      endCompanyId: data['endCompany']?.toString(),
      memo: data['memo'] ?? '',
    );
  }

  // フォームの出力用にMapに変換（データベース保存用）
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'isAllDay': isAllDay,
      'startTime': startTime != null
          ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'endTime': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'meetingType': meetingType,
      'url': url,
      'agent':
          agentId != null && agentId!.isNotEmpty ? int.parse(agentId!) : null,
      'endCompany': endCompanyId != null && endCompanyId!.isNotEmpty
          ? int.parse(endCompanyId!)
          : null,
      'memo': memo,
    };
  }

  // バリデーション
  String? validateTitle() {
    if (title.isEmpty) {
      return 'タイトルを入力してください';
    }
    return null;
  }

  String? validateDate() {
    if (date == null) {
      return '日付を選択してください';
    }
    return null;
  }

  String? validateTime() {
    if (!isAllDay && (startTime == null || endTime == null)) {
      return '開始時刻と終了時刻を選択するか、終日にチェックを入れてください';
    }
    return null;
  }
}
