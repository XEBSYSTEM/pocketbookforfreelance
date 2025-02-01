import 'package:flutter/material.dart';
import 'package:pocketbookforfreelance/company_detail.dart';
import 'package:pocketbookforfreelance/company_form.dart';
import 'package:pocketbookforfreelance/db/database_helper.dart';
import 'package:pocketbookforfreelance/models/schedule_form_data.dart';
import 'package:pocketbookforfreelance/widgets/schedule_form/basic_info_section.dart';
import 'package:pocketbookforfreelance/widgets/schedule_form/time_section.dart';
import 'package:pocketbookforfreelance/widgets/schedule_form/meeting_type_section.dart';
import 'package:pocketbookforfreelance/widgets/schedule_form/company_section.dart';
import 'package:pocketbookforfreelance/widgets/schedule_form/memo_section.dart';

class ScheduleForm extends StatefulWidget {
  final DateTime? initialDate;
  final Map<String, dynamic>? initialData;
  final bool isEditing;

  const ScheduleForm({
    super.key,
    this.initialDate,
    this.initialData,
    this.isEditing = false,
  });

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _memoController = TextEditingController();
  late ScheduleFormData _formData;
  final List<String> _meetingTypes = ['', '対面', 'リモート'];
  List<Map<String, dynamic>> _agents = [
    {'id': '', 'company_name': '選択してください'}
  ];
  List<Map<String, dynamic>> _endCompanies = [
    {'id': '', 'company_name': '選択してください'}
  ];

  Future<void> _loadCompanies() async {
    try {
      // エージェント企業を取得
      final agentCompanies =
          await DatabaseHelper.instance.readCompaniesByType(CompanyType.agent);
      setState(() {
        _agents = [
          {'id': '', 'company_name': '選択してください'},
          ...agentCompanies,
        ];
      });

      // エンド企業を取得
      final endCompanies =
          await DatabaseHelper.instance.readCompaniesByType(CompanyType.end);
      setState(() {
        _endCompanies = [
          {'id': '', 'company_name': '選択してください'},
          ...endCompanies,
        ];
      });
    } catch (e) {
      print('企業データの取得に失敗しました: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCompanies();

    // フォームデータの初期化
    if (widget.initialData != null) {
      _formData = ScheduleFormData.fromMap(widget.initialData!);
      _titleController.text = _formData.title;
      _urlController.text = _formData.url ?? '';
      _memoController.text = _formData.memo ?? '';
    } else {
      _formData = ScheduleFormData(
        date: widget.initialDate,
      );
    }
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
      initialDate: _formData.date ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025, 12, 31),
    );
    if (pickedDate != null) {
      setState(() {
        _formData.date = pickedDate;
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
          _formData.startTime = pickedTime;
        } else {
          _formData.endTime = pickedTime;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formData.title = _titleController.text;
      _formData.url = _urlController.text;
      _formData.memo = _memoController.text;
      Navigator.pop(context, _formData.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'スケジュール編集' : 'スケジュール登録'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BasicInfoSection(
                  formData: _formData,
                  titleController: _titleController,
                  onSelectDate: _selectDate,
                ),
                const SizedBox(height: 16),

                TimeSection(
                  formData: _formData,
                  onAllDayChanged: (value) {
                    setState(() {
                      _formData.isAllDay = value ?? false;
                      if (_formData.isAllDay) {
                        _formData.startTime = null;
                        _formData.endTime = null;
                      }
                    });
                  },
                  onSelectStartTime: () => _selectTime(true),
                  onSelectEndTime: () => _selectTime(false),
                ),
                const SizedBox(height: 16),

                MeetingTypeSection(
                  formData: _formData,
                  meetingTypes: _meetingTypes,
                  onMeetingTypeChanged: (value) {
                    setState(() {
                      _formData.meetingType = value;
                    });
                  },
                  urlController: _urlController,
                ),
                const SizedBox(height: 16),

                CompanySection(
                  formData: _formData,
                  agents: _agents,
                  endCompanies: _endCompanies,
                  onAgentChanged: (value) {
                    setState(() {
                      _formData.agentId = value;
                    });
                  },
                  onEndCompanyChanged: (value) {
                    setState(() {
                      _formData.endCompanyId = value;
                    });
                  },
                  onAgentRegisterPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyForm(
                          title: 'エージェント登録',
                          companyType: CompanyType.agent,
                        ),
                      ),
                    ).then((_) => _loadCompanies());
                  },
                  onEndCompanyRegisterPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyForm(
                          title: 'エンド企業登録',
                          companyType: CompanyType.end,
                        ),
                      ),
                    ).then((_) => _loadCompanies());
                  },
                ),
                const SizedBox(height: 16),

                MemoSection(
                  formData: _formData,
                  memoController: _memoController,
                ),
                const SizedBox(height: 24),

                // 登録/更新ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _formData.date != null &&
                          (_formData.isAllDay ||
                              (_formData.startTime != null &&
                                  _formData.endTime != null))) {
                        _submitForm();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.isEditing ? '更新' : '登録'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
