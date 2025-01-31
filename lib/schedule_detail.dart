import 'package:flutter/material.dart';
import 'schedule_form.dart';

class ScheduleDetail extends StatelessWidget {
  final Map<String, dynamic> scheduleData;

  const ScheduleDetail({
    super.key,
    required this.scheduleData,
  });

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

  @override
  Widget build(BuildContext context) {
    final date = scheduleData['date'] as DateTime?;
    final startTime = scheduleData['startTime'] as TimeOfDay?;
    final endTime = scheduleData['endTime'] as TimeOfDay?;
    final isAllDay = scheduleData['isAllDay'] as bool? ?? false;

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
                  _buildInfoTile('タイトル', scheduleData['title'] ?? ''),
                  _buildInfoTile('日付', dateStr),
                  _buildInfoTile('時間', timeStr),
                  _buildInfoTile('種別', scheduleData['meetingType'] ?? ''),
                  if (scheduleData['url']?.isNotEmpty ?? false)
                    _buildInfoTile('URL', scheduleData['url'] ?? ''),
                  _buildInfoTile('エージェント', scheduleData['agent'] ?? ''),
                  _buildInfoTile('エンド企業', scheduleData['endCompany'] ?? ''),
                  if (scheduleData['memo']?.isNotEmpty ?? false)
                    _buildInfoTile('メモ', scheduleData['memo'] ?? ''),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleForm(
                          initialDate: scheduleData['date'],
                          initialData: scheduleData,
                          isEditing: true,
                        ),
                      ),
                    );
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
                        content:
                            Text('「${scheduleData['title']}」を削除してもよろしいですか？'),
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
