import 'package:flutter/material.dart';
import 'company_detail.dart';
import 'db/database_helper.dart';
import 'db/schedule_repository.dart';

class ScheduleEdit extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final int scheduleId;

  const ScheduleEdit({
    super.key,
    required this.initialData,
    required this.scheduleId,
  });

  @override
  State<ScheduleEdit> createState() => _ScheduleEditState();
}

class _ScheduleEditState extends State<ScheduleEdit> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isAllDay = false;
  String? _meetingType;
  int? _selectedAgent;
  int? _selectedEndCompany;

  // データリスト
  List<Map<String, dynamic>> _agents = [];
  List<Map<String, dynamic>> _endCompanies = [];
  final List<String> _meetingTypes = ['', '対面', 'リモート'];

  Future<void> _loadCompanies() async {
    try {
      final agents =
          await DatabaseHelper.instance.readCompaniesByType(CompanyType.agent);
      final endCompanies =
          await DatabaseHelper.instance.readCompaniesByType(CompanyType.end);

      setState(() {
        _agents = agents;
        _endCompanies = endCompanies;
      });
    } catch (e) {
      print('Error loading companies: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _selectedDate = widget.initialData['date'];
    _titleController.text = widget.initialData['title'] ?? '';
    _isAllDay = widget.initialData['isAllDay'] ?? false;
    _startTime = widget.initialData['startTime'] is String
        ? TimeOfDay(
            hour: int.parse(widget.initialData['startTime'].split(':')[0]),
            minute: int.parse(widget.initialData['startTime'].split(':')[1]))
        : widget.initialData['startTime'];
    _endTime = widget.initialData['endTime'] is String
        ? TimeOfDay(
            hour: int.parse(widget.initialData['endTime'].split(':')[0]),
            minute: int.parse(widget.initialData['endTime'].split(':')[1]))
        : widget.initialData['endTime'];
    _meetingType = widget.initialData['meetingType'];
    _urlController.text = widget.initialData['url'] ?? '';
    // 数値型の場合はそのまま使用し、文字列の場合は変換する
    _selectedAgent = widget.initialData['agent'] != null
        ? (widget.initialData['agent'] is int
            ? widget.initialData['agent']
            : int.parse(widget.initialData['agent'].toString()))
        : null;
    _selectedEndCompany = widget.initialData['endCompany'] != null
        ? (widget.initialData['endCompany'] is int
            ? widget.initialData['endCompany']
            : int.parse(widget.initialData['endCompany'].toString()))
        : null;
    _memoController.text = widget.initialData['memo'] ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _memoController.dispose();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        (_isAllDay || (_startTime != null && _endTime != null))) {
      try {
        final db = await DatabaseHelper.instance.database;
        final repository = ScheduleRepository(db);

        final scheduleData = {
          'title': _titleController.text,
          'date': _selectedDate,
          'isAllDay': _isAllDay,
          'startTime':
              _startTime != null ? _formatTimeOfDay(_startTime!) : null,
          'endTime': _endTime != null ? _formatTimeOfDay(_endTime!) : null,
          'meetingType': _meetingType,
          'url': _urlController.text,
          'agent': _selectedAgent,
          'endCompany': _selectedEndCompany,
          'memo': _memoController.text,
        };

        await repository.updateSchedule(widget.scheduleId, scheduleData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('スケジュールを更新しました')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール編集'),
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
                value: _meetingType,
                items: _meetingTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.isEmpty ? '選択してください' : type,
                            style: const TextStyle(color: Colors.black),
                          ),
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
              const SizedBox(height: 16),

              // エージェント
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'エージェント',
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
                value: _selectedAgent != null &&
                        _agents.any((a) => a['id'] == _selectedAgent)
                    ? _selectedAgent
                    : null,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      '選択してください',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ..._agents.map((agent) => DropdownMenuItem<int>(
                        value: agent['id'],
                        child: Text(
                          agent['company_name'],
                          style: const TextStyle(color: Colors.black),
                        ),
                      )),
                ],
                onChanged: (int? value) {
                  setState(() {
                    _selectedAgent = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // エンド企業
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'エンド企業',
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
                value: _selectedEndCompany != null &&
                        _endCompanies.any((c) => c['id'] == _selectedEndCompany)
                    ? _selectedEndCompany
                    : null,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      '選択してください',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ..._endCompanies.map((company) => DropdownMenuItem<int>(
                        value: company['id'],
                        child: Text(
                          company['company_name'],
                          style: const TextStyle(color: Colors.black),
                        ),
                      )),
                ],
                onChanged: (int? value) {
                  setState(() {
                    _selectedEndCompany = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // メモ
              TextFormField(
                controller: _memoController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                minLines: 3,
              ),
              const SizedBox(height: 24),

              // 更新ボタン
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
                  child: const Text('更新'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
