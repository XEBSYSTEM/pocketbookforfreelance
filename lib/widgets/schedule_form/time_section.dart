import 'package:flutter/material.dart';
import '../../models/schedule_form_data.dart';

class TimeSection extends StatelessWidget {
  final ScheduleFormData formData;
  final ValueChanged<bool?> onAllDayChanged;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;

  const TimeSection({
    super.key,
    required this.formData,
    required this.onAllDayChanged,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
  });

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 終日チェックボックス
        CheckboxListTile(
          title: const Text('終日'),
          value: formData.isAllDay,
          onChanged: onAllDayChanged,
        ),
        const SizedBox(height: 16),

        // 開始時刻と終了時刻
        if (!formData.isAllDay) ...[
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(formData.startTime == null
                      ? '開始時刻を選択'
                      : '開始: ${_formatTimeOfDay(formData.startTime)}'),
                  trailing: const Icon(Icons.access_time),
                  tileColor: Colors.grey[200],
                  onTap: onSelectStartTime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListTile(
                  title: Text(formData.endTime == null
                      ? '終了時刻を選択'
                      : '終了: ${_formatTimeOfDay(formData.endTime)}'),
                  trailing: const Icon(Icons.access_time),
                  tileColor: Colors.grey[200],
                  onTap: onSelectEndTime,
                ),
              ),
            ],
          ),
          if (!formData.isAllDay &&
              formData.startTime == null &&
              formData.endTime == null)
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 8),
              child: Text(
                '開始時刻と終了時刻を選択するか、終日にチェックを入れてください',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ],
    );
  }
}
