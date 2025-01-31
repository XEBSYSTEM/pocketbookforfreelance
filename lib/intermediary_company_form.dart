import 'package:flutter/material.dart';

class IntermediaryCompanyForm extends StatefulWidget {
  const IntermediaryCompanyForm({super.key});

  @override
  State<IntermediaryCompanyForm> createState() =>
      _IntermediaryCompanyFormState();
}

class _IntermediaryCompanyFormState extends State<IntermediaryCompanyForm> {
  final _formKey = GlobalKey<FormState>();

  // フォームの入力値
  String _companyName = '';
  String _address = '';
  String _phone = '';
  String _personInCharge = '';
  String _department = '';
  String _position = '';
  String _email = '';
  String _commission = ''; // 手数料

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('中間請け企業登録'),
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

              // 住所
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '住所',
                  hintText: '例：東京都渋谷区...',
                  filled: true,
                ),
                onSaved: (value) {
                  _address = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 電話番号
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '電話番号',
                  hintText: '例：03-1234-5678',
                  filled: true,
                ),
                onSaved: (value) {
                  _phone = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 担当者名
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '担当者名',
                  hintText: '例：山田太郎',
                  filled: true,
                ),
                onSaved: (value) {
                  _personInCharge = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 部署
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '部署',
                  hintText: '例：営業部',
                  filled: true,
                ),
                onSaved: (value) {
                  _department = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 役職
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '役職',
                  hintText: '例：部長',
                  filled: true,
                ),
                onSaved: (value) {
                  _position = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // メールアドレス
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  hintText: '例：yamada@example.com',
                  filled: true,
                ),
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 手数料
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '手数料',
                  hintText: '例：10%',
                  filled: true,
                ),
                onSaved: (value) {
                  _commission = value ?? '';
                },
              ),
              const SizedBox(height: 32),

              // 登録ボタン
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // フォームの値をMapにまとめる
                    final intermediaryCompanyData = {
                      'companyName': _companyName,
                      'address': _address,
                      'phone': _phone,
                      'personInCharge': _personInCharge,
                      'department': _department,
                      'position': _position,
                      'email': _email,
                      'commission': _commission,
                    };
                    // 前の画面に値を返す
                    Navigator.pop(context, intermediaryCompanyData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
