import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('タブアプリ'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'スケジュール'),
              Tab(icon: Icon(Icons.business), text: '仕事'),
              Tab(icon: Icon(Icons.school), text: '学習'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScheduleTab(),
            const Center(child: Text('仕事画面')),
            const Center(child: Text('学習画面')),
          ],
        ),
      ),
    );
  }
}

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
      // TODO: 返されたデータを使用してスケジュールを追加
      print('新しいスケジュール: $result');
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
      // TODO: 返されたデータを使用してスケジュールを更新
      print('更新されたスケジュール: $result');
    }
  }

  void _deleteSchedule(int index) {
    // TODO: スケジュール削除の処理を実装
    print('スケジュール削除ボタンが押されました: $index');
  }

  Widget _buildAddScheduleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: _addSchedule,
        icon: const Icon(Icons.add),
        label: const Text('スケジュールを追加する'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
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
