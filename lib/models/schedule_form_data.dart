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

  // 入力データからインスタンスを作成
  factory ScheduleFormData.fromMap(Map<String, dynamic> data) {
    return ScheduleFormData(
      title: data['title'] ?? '',
      date: data['date'],
      isAllDay: data['isAllDay'] ?? false,
      startTime: data['startTime'],
      endTime: data['endTime'],
      meetingType: data['meetingType'],
      url: data['url'] ?? '',
      agentId: data['agent'],
      endCompanyId: data['endCompany'],
      memo: data['memo'] ?? '',
    );
  }

  // フォームの出力用にMapに変換
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'isAllDay': isAllDay,
      'startTime': startTime,
      'endTime': endTime,
      'meetingType': meetingType,
      'url': url,
      'agent': agentId,
      'endCompany': endCompanyId,
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
