import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../schedule_form.dart';
import '../schedule_detail.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // サンプルの予定データ
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2025, 1, 30): [
      {
        'time': '09:00',
        'title': '朝のミーティング',
        'isAllDay': false,
        'startTime': const TimeOfDay(hour: 9, minute: 0),
        'endTime': const TimeOfDay(hour: 10, minute: 0),
        'meetingType': '対面',
        'url': 'https://example.com',
        'agent': 'エージェントA',
        'endCompany': 'エンドA',
        'memo': '重要な案件について議論する予定',
      },
      {
        'time': '13:00',
        'title': 'ランチミーティング',
        'isAllDay': false,
        'startTime': const TimeOfDay(hour: 13, minute: 0),
        'endTime': const TimeOfDay(hour: 14, minute: 0),
        'meetingType': 'リモート',
        'url': 'https://meet.example.com',
        'agent': 'エージェントB',
        'endCompany': 'エンドB',
        'memo': 'ランチを取りながらの打ち合わせ',
      },
    ],
    DateTime(2025, 1, 31): [
      {
        'time': '10:00',
        'title': 'プロジェクト会議',
        'isAllDay': false,
        'startTime': const TimeOfDay(hour: 10, minute: 0),
        'endTime': const TimeOfDay(hour: 11, minute: 0),
        'meetingType': '対面',
        'url': '',
        'agent': 'エージェントA',
        'endCompany': 'エンドA',
        'memo': '進捗報告と今後のスケジュール確認',
      },
      {
        'time': '15:00',
        'title': 'クライアントとの打ち合わせ',
        'isAllDay': false,
        'startTime': const TimeOfDay(hour: 15, minute: 0),
        'endTime': const TimeOfDay(hour: 16, minute: 0),
        'meetingType': 'リモート',
        'url': 'https://client.example.com',
        'agent': 'エージェントB',
        'endCompany': 'エンドB',
        'memo': '要件定義の最終確認',
      },
    ],
  };

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleForm(
          initialDate: _selectedDay ?? _focusedDay,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final date = _selectedDay ?? _focusedDay;
        final key = DateTime(date.year, date.month, date.day);
        if (!_events.containsKey(key)) {
          _events[key] = [];
        }
        _events[key]!.add(result as Map<String, dynamic>);
      });
    }
  }

  void _editSchedule(int index) async {
    if (_selectedDay == null) return;

    final events = _getEventsForDay(_selectedDay!);
    if (index >= events.length) return;

    final event = events[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleForm(
          initialDate: _selectedDay,
          initialData: event,
          isEditing: true,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final key = DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        _events[key]![index] = result as Map<String, dynamic>;
      });
    }
  }

  Future<void> _deleteSchedule(int index) async {
    if (_selectedDay == null) return;

    final events = _getEventsForDay(_selectedDay!);
    if (index >= events.length) return;

    final event = events[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スケジュールの削除'),
        content: Text('「${event['title']}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        final key = DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        final dayEvents = _events[key];
        if (dayEvents != null) {
          dayEvents.removeAt(index);
          if (dayEvents.isEmpty) {
            _events.remove(key);
          }
        }
      });
    }
  }

  Widget _buildAddScheduleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: _addSchedule,
        icon: const Icon(Icons.add),
        label: const Text('スケジュールを追加する'),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_selectedDay == null) {
      return const Center(child: Text('日付を選択してください'));
    }

    final events = _getEventsForDay(_selectedDay!);
    if (events.isEmpty) {
      return const Center(child: Text('予定はありません'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              '${event['time']}　${event['title']}',
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleDetail(
                    scheduleData: {
                      ...event,
                      'date': _selectedDay,
                    },
                  ),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editSchedule(index),
                  tooltip: '編集',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSchedule(index),
                  tooltip: '削除',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          eventLoader: _getEventsForDay,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _buildEventsList(),
                ),
                _buildAddScheduleButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
