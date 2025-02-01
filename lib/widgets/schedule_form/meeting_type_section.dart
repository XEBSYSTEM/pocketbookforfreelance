import 'package:flutter/material.dart';
import '../../models/schedule_form_data.dart';

class MeetingTypeSection extends StatelessWidget {
  final ScheduleFormData formData;
  final List<String> meetingTypes;
  final ValueChanged<String?> onMeetingTypeChanged;
  final TextEditingController urlController;

  const MeetingTypeSection({
    super.key,
    required this.formData,
    required this.meetingTypes,
    required this.onMeetingTypeChanged,
    required this.urlController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 種別（ドロップダウン）
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: '種別',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          value: formData.meetingType,
          items: meetingTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(
                      type.isEmpty ? '選択してください' : type,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ))
              .toList(),
          onChanged: onMeetingTypeChanged,
        ),
        const SizedBox(height: 16),

        // URL
        TextFormField(
          controller: urlController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'URL',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }
}
