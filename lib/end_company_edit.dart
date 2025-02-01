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

  // 共通フィールド
  late String _companyName;
  late String _personInCharge;
  late String _email;
  late String _phone;
  late String _address;

  // エンド企業固有のフィールド
  late String _department;
  late String _position;

  @override
  void initState() {
    super.initState();
    // 初期値の設定
    _companyName = widget.initialData['company_name'] ?? '';
    _personInCharge = widget.initialData['person_in_charge'] ?? '';
    _email = widget.initialData['person_email'] ?? '';
    _phone = widget.initialData['person_phone'] ?? '';
    _address = widget.initialData['address'] ?? '';

    // エンド企業固有のフィールド
    _department = widget.initialData['department'] ?? '';
    _position = widget.initialData['position'] ?? '';
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
              // 共通フィールド
              _buildCommonFields(),

              // エンド企業固有のフィールド
              ..._buildEndCompanyFields(),

              const SizedBox(height: 32),

              // 更新ボタン
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final updatedData = _getUpdatedData();
                    _updateCompany(updatedData).then((_) {
                      _navigateToDetail(updatedData);
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

  // 共通フィールドを構築
  Widget _buildCommonFields() {
    return Column(
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
      ],
    );
  }

  // エンド企業固有のフィールドを構築
  List<Widget> _buildEndCompanyFields() {
    return [
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: '部署',
          hintText: '例：営業部',
          filled: true,
        ),
        initialValue: _department,
        onSaved: (value) {
          _department = value ?? '';
        },
      ),
      const SizedBox(height: 16),
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
    ];
  }

  // 更新用のデータを取得（データベースのカラム名に合わせる）
  Map<String, dynamic> _getUpdatedData() {
    return {
      'companyName': _companyName,
      'personInCharge': _personInCharge,
      'personEmail': _email,
      'personPhone': _phone,
      'address': _address,
      'companyType': CompanyType.end.name,
      'department': _department,
      'position': _position,
    };
  }

  // データベースを更新
  Future<void> _updateCompany(Map<String, dynamic> data) async {
    await DatabaseHelper.instance.updateCompany(widget.companyId, data);
  }

  // 詳細画面に戻る
  void _navigateToDetail(Map<String, dynamic> data) {
    Navigator.pop(context, true); // 更新されたことを示すtrueを渡す
  }
}
