import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'company_detail.dart';

class EndCompanyEdit extends StatefulWidget {
  final int companyId;
  final Map<String, dynamic> initialData;

  const EndCompanyEdit({
    super.key,
    required this.companyId,
    required this.initialData,
  });

  @override
  State<EndCompanyEdit> createState() => _EndCompanyEditState();
}

class _EndCompanyEditState extends State<EndCompanyEdit> {
  final _formKey = GlobalKey<FormState>();

  late String _companyName;
  late String _address;
  late String _phone;
  late String _personInCharge;
  late String _department;
  late String _position;
  late String _email;

  @override
  void initState() {
    super.initState();
    // 初期値の設定
    _companyName = widget.initialData['company_name'] ?? '';
    _address = widget.initialData['branch_address'] ?? '';
    _phone = widget.initialData['branch_phone'] ?? '';
    _personInCharge = widget.initialData['person_in_charge'] ?? '';
    _department = widget.initialData['department'] ?? '';
    _position = widget.initialData['position'] ?? '';
    _email = widget.initialData['person_email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エンド企業編集'),
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

              // 住所
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '住所',
                  hintText: '例：東京都渋谷区...',
                  filled: true,
                ),
                initialValue: _address,
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
                initialValue: _phone,
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
                initialValue: _personInCharge,
                onSaved: (value) {
                  _personInCharge = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // 部署
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '部署',
                  hintText: '例：人事部',
                  filled: true,
                ),
                initialValue: _department,
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
                initialValue: _position,
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
                initialValue: _email,
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              const SizedBox(height: 32),

              // 更新ボタン
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // フォームの値をMapにまとめる
                    final updatedData = {
                      'companyName': _companyName,
                      'branchAddress': _address,
                      'branchPhone': _phone,
                      'personInCharge': _personInCharge,
                      'department': _department,
                      'position': _position,
                      'personEmail': _email,
                      'companyType': CompanyType.end.name,
                    };
                    // データベースを更新
                    _updateEndCompany(updatedData).then((_) {
                      // エンド企業詳細画面に戻る
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompanyDetail(
                            companyId: widget.companyId,
                            companyType: CompanyType.end,
                          ),
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

  Future<void> _updateEndCompany(Map<String, dynamic> data) async {
    await DatabaseHelper.instance.updateCompany(widget.companyId, data);
  }
}
