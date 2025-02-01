import 'package:flutter/material.dart';
import 'schedule_edit.dart';
import 'db/database_helper.dart';
import 'db/company_repository.dart';

class ScheduleDetail extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const ScheduleDetail({
    super.key,
    required this.scheduleData,
  });

  @override
  State<ScheduleDetail> createState() => _ScheduleDetailState();
}

class _ScheduleDetailState extends State<ScheduleDetail> {
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  late Future<Map<String, String>> _companyNamesFuture;

  @override
  void initState() {
    super.initState();
    _companyNamesFuture = _loadCompanyNames();
  }

  Future<Map<String, String>> _loadCompanyNames() async {
    final db = await DatabaseHelper.instance.database;
    final companyRepo = CompanyRepository(db);
    final Map<String, String> names = {};

    // エージェントの企業名を取得
    if (widget.scheduleData['agent'] != null) {
      final agentCompany = await companyRepo
          .readCompany(int.parse(widget.scheduleData['agent']));
      if (agentCompany != null) {
        names['agent'] = agentCompany['company_name'];
      }
    }

    // エンド企業の企業名を取得
    if (widget.scheduleData['endCompany'] != null) {
      final endCompany = await companyRepo
          .readCompany(int.parse(widget.scheduleData['endCompany']));
      if (endCompany != null) {
        names['endCompany'] = endCompany['company_name'];
      }
    }

    return names;
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.scheduleData['date'] as DateTime?;
    final startTime = widget.scheduleData['startTime'] as TimeOfDay?;
    final endTime = widget.scheduleData['endTime'] as TimeOfDay?;
    final isAllDay = widget.scheduleData['isAllDay'] as bool? ?? false;

    String dateStr =
        date == null ? '未設定' : '${date.year}/${date.month}/${date.day}';

    String timeStr = isAllDay
        ? '終日'
        : '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール詳細'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoTile('タイトル', widget.scheduleData['title'] ?? ''),
                  _buildInfoTile('日付', dateStr),
                  _buildInfoTile('時間', timeStr),
                  _buildInfoTile(
                      '種別', widget.scheduleData['meetingType'] ?? ''),
                  if (widget.scheduleData['url']?.isNotEmpty ?? false)
                    _buildInfoTile('URL', widget.scheduleData['url'] ?? ''),
                  FutureBuilder<Map<String, String>>(
                    future: _companyNamesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final names = snapshot.data!;
                        return Column(
                          children: [
                            _buildInfoTile('エージェント', names['agent'] ?? '未設定'),
                            _buildInfoTile(
                                'エンド企業', names['endCompany'] ?? '未設定'),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('エラーが発生しました: ${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                  if (widget.scheduleData['memo']?.isNotEmpty ?? false)
                    _buildInfoTile('メモ', widget.scheduleData['memo'] ?? ''),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleEdit(
                          initialData: widget.scheduleData,
                          scheduleId: widget.scheduleData['id'],
                        ),
                      ),
                    );

                    if (result == true) {
                      Navigator.pop(context, {'action': 'edited'});
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text('編集'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('スケジュールの削除'),
                        content: Text(
                            '「${widget.scheduleData['title']}」を削除してもよろしいですか？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('削除'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      Navigator.pop(context, {'action': 'delete'});
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('削除'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
