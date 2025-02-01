import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../schedule_form.dart';
import '../schedule_edit.dart';
import '../schedule_detail.dart';
import '../db/database_helper.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      // 現在の月の最初の日と最後の日を取得
      final now = _focusedDay;
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      // 月全体のスケジュールを取得
      final schedules = await Future.wait(
        List.generate(
          lastDay.day,
          (index) => DatabaseHelper.instance
              .readSchedulesByDate(DateTime(now.year, now.month, index + 1)),
        ),
      );

      final timeStringToTimeOfDay = (String? timeStr) {
        if (timeStr == null) return null;
        final parts = timeStr.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      };

      // 新しいイベントマップを作成
      final newEvents = <DateTime, List<Map<String, dynamic>>>{};

      for (var i = 0; i < lastDay.day; i++) {
        final date = DateTime(now.year, now.month, i + 1);
        final key = DateTime(date.year, date.month, date.day);

        if (schedules[i].isNotEmpty) {
          newEvents[key] = schedules[i]
              .map((schedule) => {
                    'id': schedule['id'],
                    'title': schedule['title'],
                    'isAllDay': schedule['is_all_day'] == 1,
                    'startTime': timeStringToTimeOfDay(schedule['start_time']),
                    'endTime': timeStringToTimeOfDay(schedule['end_time']),
                    'meetingType': schedule['meeting_type'],
                    'url': schedule['url'],
                    'agent': schedule['agent_id']?.toString(),
                    'endCompany': schedule['end_company_id']?.toString(),
                    'memo': schedule['memo'],
                  })
              .toList();
        }
      }

      setState(() {
        _events = newEvents;
      });
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _addSchedule() async {
    if (!mounted) return;

    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScheduleForm(
            initialDate: _selectedDay ?? _focusedDay,
          ),
        ),
      );

      if (result != null && mounted) {
        await DatabaseHelper.instance
            .createSchedule(result as Map<String, dynamic>);
        await _loadSchedules();
      }
    } catch (e) {
      print('Error creating schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スケジュールの作成に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editSchedule(int index) async {
    if (_selectedDay == null) return;

    final events = _getEventsForDay(_selectedDay!);
    if (index >= events.length) return;

    final event = events[index];
    final scheduleId = _events[DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]![index]
        ['id'];

    if (!mounted) return;

    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScheduleEdit(
            initialData: {
              ...event,
              'date': _selectedDay,
            },
            scheduleId: scheduleId,
          ),
        ),
      );

      if (result == true && mounted) {
        await _loadSchedules();
      }
    } catch (e) {
      print('Error editing schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スケジュールの編集に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSchedule(int index) async {
    final scheduleId = _events[DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]![index]
        ['id'];
    if (_selectedDay == null) return;

    final events = _getEventsForDay(_selectedDay!);
    if (index >= events.length) return;

    final event = events[index];
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
      try {
        await DatabaseHelper.instance.deleteSchedule(scheduleId);
        setState(() {});
        await _loadSchedules();
      } catch (e) {
        print('Error deleting schedule: $e');
      }
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

    final events = _events[DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ??
        [];
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
              '${event['isAllDay'] ? '終日' : event['startTime'] != null ? '${event['startTime'].format(context)}' : ''}　${event['title']}',
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () async {
              if (!mounted) return;

              try {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScheduleDetail(
                      scheduleData: {
                        ...event,
                        'date': _selectedDay,
                      },
                    ),
                  ),
                );

                if (result != null && mounted) {
                  if (result['action'] == 'delete' ||
                      result['action'] == 'edited') {
                    try {
                      if (result['action'] == 'delete') {
                        final scheduleId = events[index]['id'];
                        await DatabaseHelper.instance
                            .deleteSchedule(scheduleId);
                      }
                      await _loadSchedules();
                    } catch (e) {
                      print('Error processing schedule action: $e');
                    }
                  }
                }
              } catch (e) {
                print('Error navigating to schedule detail: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('スケジュールの詳細表示に失敗しました'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
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
              _loadSchedules();
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
