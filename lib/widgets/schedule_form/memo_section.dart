import 'package:flutter/material.dart';
import '../../models/schedule_form_data.dart';

class MemoSection extends StatelessWidget {
  final ScheduleFormData formData;
  final TextEditingController memoController;

  const MemoSection({
    super.key,
    required this.formData,
    required this.memoController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: memoController,
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        labelText: 'メモ',
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
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      minLines: 3,
    );
  }
}
