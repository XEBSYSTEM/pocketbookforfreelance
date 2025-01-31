import 'package:flutter/material.dart';
import 'db/database_helper.dart';

class AgentForm extends StatefulWidget {
  const AgentForm({super.key});

  @override
  State<AgentForm> createState() => _AgentFormState();
}

class _AgentFormState extends State<AgentForm> {
  final _formKey = GlobalKey<FormState>();

  // フォームの入力値
  String _companyName = '';
  String _branchAddress = '';
  String _branchPhone = '';
  String _headOfficeAddress = '';
  String _headOfficePhone = '';
  String _personInCharge = '';
  String _personPhone = '';
  String _personEmail = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エージェント登録'),
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
                onSaved: (value) {
                  _personEmail = value ?? '';
                },
              ),
              const SizedBox(height: 32),

              // 登録ボタン
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // フォームの値をMapにまとめる
                    final agentData = {
                      'companyType': 1, // エージェントは1
                      'companyName': _companyName,
                      'branchAddress': _branchAddress,
                      'branchPhone': _branchPhone,
                      'headOfficeAddress': _headOfficeAddress,
                      'headOfficePhone': _headOfficePhone,
                      'personInCharge': _personInCharge,
                      'personPhone': _personPhone,
                      'personEmail': _personEmail,
                    };

                    // データベースに保存
                    try {
                      final id = await DatabaseHelper.instance
                          .createCompany(agentData);
                      if (context.mounted) {
                        Navigator.pop(context, agentData);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('エージェントの登録に失敗しました'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('登録する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
