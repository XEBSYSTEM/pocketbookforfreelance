import 'package:flutter/material.dart';
import '../../models/schedule_form_data.dart';

class BasicInfoSection extends StatelessWidget {
  final ScheduleFormData formData;
  final TextEditingController titleController;
  final VoidCallback onSelectDate;

  const BasicInfoSection({
    super.key,
    required this.formData,
    required this.titleController,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // タイトル
        TextFormField(
          controller: titleController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'タイトル *',
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
          validator: (_) => formData.validateTitle(),
          onChanged: (value) {
            formData.title = value;
          },
        ),
        const SizedBox(height: 16),

        // 日付
        ListTile(
          title: Text(formData.date == null
              ? '日付を選択 *'
              : '日付: ${formData.date!.year}/${formData.date!.month}/${formData.date!.day}'),
          trailing: const Icon(Icons.calendar_today),
          tileColor: Colors.grey[200],
          onTap: onSelectDate,
        ),
        if (formData.date == null)
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: Text(
              '日付を選択してください',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
