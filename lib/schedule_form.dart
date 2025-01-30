import 'package:flutter/material.dart';

class ScheduleForm extends StatefulWidget {
  final DateTime? initialDate;

  const ScheduleForm({super.key, this.initialDate});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isAllDay = false;
  String? _meetingType;
  final _urlController = TextEditingController();
  String? _selectedAgent;
  String? _selectedEndCompany;

  // ダミーデータ
  final List<String> _agents = ['', 'エージェントA', 'エージェントB'];
  final List<String> _endCompanies = ['', 'エンドA', 'エンドB'];
  final List<String> _meetingTypes = ['', '対面', 'リモート'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025, 12, 31),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: フォームデータの保存処理
      Navigator.pop(context, {
        'title': _titleController.text,
        'date': _selectedDate,
        'isAllDay': _isAllDay,
        'startTime': _startTime,
        'endTime': _endTime,
        'meetingType': _meetingType,
        'url': _urlController.text,
        'agent': _selectedAgent,
        'endCompany': _selectedEndCompany,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール登録'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 日付
              ListTile(
                title: Text(_selectedDate == null
                    ? '日付を選択 *'
                    : '日付: ${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'),
                trailing: const Icon(Icons.calendar_today),
                tileColor: Colors.grey[200],
                onTap: _selectDate,
              ),
              if (_selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    '日付を選択してください',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // 終日チェックボックス
              CheckboxListTile(
                title: const Text('終日'),
                value: _isAllDay,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllDay = value ?? false;
                    if (_isAllDay) {
                      _startTime = null;
                      _endTime = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // 開始時刻と終了時刻
              if (!_isAllDay) ...[
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(_startTime == null
                            ? '開始時刻を選択'
                            : '開始: ${_formatTimeOfDay(_startTime)}'),
                        trailing: const Icon(Icons.access_time),
                        tileColor: Colors.grey[200],
                        onTap: () => _selectTime(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListTile(
                        title: Text(_endTime == null
                            ? '終了時刻を選択'
                            : '終了: ${_formatTimeOfDay(_endTime)}'),
                        trailing: const Icon(Icons.access_time),
                        tileColor: Colors.grey[200],
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ],
                ),
                if (!_isAllDay && _startTime == null && _endTime == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 8),
                    child: Text(
                      '開始時刻と終了時刻を選択するか、終日にチェックを入れてください',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: 16),

              // 種別（ドロップダウン）
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '種別',
                  border: OutlineInputBorder(),
                ),
                value: _meetingType,
                items: _meetingTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.isEmpty ? '選択してください' : type),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _meetingType = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // エージェント
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'エージェント',
                  border: OutlineInputBorder(),
                ),
                value: _selectedAgent,
                items: _agents
                    .map((agent) => DropdownMenuItem(
                          value: agent,
                          child: Text(agent.isEmpty ? '選択してください' : agent),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedAgent = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // エンド企業
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'エンド企業',
                  border: OutlineInputBorder(),
                ),
                value: _selectedEndCompany,
                items: _endCompanies
                    .map((company) => DropdownMenuItem(
                          value: company,
                          child: Text(company.isEmpty ? '選択してください' : company),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedEndCompany = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 登録ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDate != null &&
                        (_isAllDay ||
                            (_startTime != null && _endTime != null))) {
                      _submitForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('登録'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
