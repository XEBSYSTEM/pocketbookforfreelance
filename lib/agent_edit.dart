import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'agent_detail.dart';

class AgentEdit extends StatefulWidget {
  final Map<String, dynamic> agentData;

  const AgentEdit({super.key, required this.agentData});

  @override
  State<AgentEdit> createState() => _AgentEditState();
}

class _AgentEditState extends State<AgentEdit> {
  final _formKey = GlobalKey<FormState>();

  late String _companyName;
  late String _branchAddress;
  late String _branchPhone;
  late String _headOfficeAddress;
  late String _headOfficePhone;
  late String _personInCharge;
  late String _personPhone;
  late String _personEmail;

  @override
  void initState() {
    super.initState();
    // 初期値の設定
    _companyName = widget.agentData['companyName'] ?? '';
    _branchAddress = widget.agentData['branchAddress'] ?? '';
    _branchPhone = widget.agentData['branchPhone'] ?? '';
    _headOfficeAddress = widget.agentData['headOfficeAddress'] ?? '';
    _headOfficePhone = widget.agentData['headOfficePhone'] ?? '';
    _personInCharge = widget.agentData['personInCharge'] ?? '';
    _personPhone = widget.agentData['personPhone'] ?? '';
    _personEmail = widget.agentData['personEmail'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エージェント編集'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 企業名（必須）
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '企業名',
                  hintText: '例：株式会社サンプル',
                  filled: true,
                ),
                initialValue: _companyName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '企業名は必須です';
                  }
                  return null;
                },
                onSaved: (value) {
                  _companyName = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 支社住所
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '支社住所',
                  hintText: '例：東京都渋谷区...',
                  filled: true,
                ),
                initialValue: _branchAddress,
                onSaved: (value) {
                  _branchAddress = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 支社電話番号
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '支社電話番号',
                  hintText: '例：03-1234-5678',
                  filled: true,
                ),
                initialValue: _branchPhone,
                onSaved: (value) {
                  _branchPhone = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 本社住所
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '本社住所',
                  hintText: '例：東京都千代田区...',
                  filled: true,
                ),
                initialValue: _headOfficeAddress,
                onSaved: (value) {
                  _headOfficeAddress = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 本社電話番号
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '本社電話番号',
                  hintText: '例：03-1234-5678',
                  filled: true,
                ),
                initialValue: _headOfficePhone,
                onSaved: (value) {
                  _headOfficePhone = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 担当者
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '担当者',
                  hintText: '例：山田太郎',
                  filled: true,
                ),
                initialValue: _personInCharge,
                onSaved: (value) {
                  _personInCharge = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 担当者電話番号
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '担当者電話番号',
                  hintText: '例：090-1234-5678',
                  filled: true,
                ),
                initialValue: _personPhone,
                onSaved: (value) {
                  _personPhone = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 担当者メールアドレス
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '担当者メールアドレス',
                  hintText: '例：yamada@example.com',
                  filled: true,
                ),
                initialValue: _personEmail,
                onSaved: (value) {
                  _personEmail = value ?? '';
                },
              ),
              const SizedBox(height: 32),

              // 更新ボタン
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // フォームの値をMapにまとめる
                    final updatedAgentData = {
                      'companyName': _companyName,
                      'branchAddress': _branchAddress,
                      'branchPhone': _branchPhone,
                      'headOfficeAddress': _headOfficeAddress,
                      'headOfficePhone': _headOfficePhone,
                      'personInCharge': _personInCharge,
                      'personPhone': _personPhone,
                      'personEmail': _personEmail,
                    };
                    // データベースを更新
                    _updateAgent(updatedAgentData).then((_) {
                      // エージェント詳細画面に戻る
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AgentDetail(agentData: widget.agentData),
                        ),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('更新する'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateAgent(Map<String, dynamic> agentData) async {
    // company_typeを1（エージェント）に設定
    agentData['companyType'] = 'agent';

    // データベースを更新
    await DatabaseHelper.instance.updateCompany(
      int.parse(widget.agentData['id'].toString()),
      agentData,
    );
  }
}
