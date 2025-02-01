import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'company_detail.dart';

class IntermediaryCompanyEdit extends StatefulWidget {
  final int companyId;
  final Map<String, dynamic> initialData;

  const IntermediaryCompanyEdit({
    super.key,
    required this.companyId,
    required this.initialData,
  });

  @override
  State<IntermediaryCompanyEdit> createState() =>
      _IntermediaryCompanyEditState();
}

class _IntermediaryCompanyEditState extends State<IntermediaryCompanyEdit> {
  final _formKey = GlobalKey<FormState>();

  // 共通フィールド
  late String _companyName;
  late String _personInCharge;
  late String _email;
  late String _phone;
  late String _address;

  // エンド企業・中間請け企業固有のフィールド
  late String _department;
  late String _position;

  // 中間請け企業固有のフィールド
  late String _commission;

  @override
  void initState() {
    super.initState();
    // 初期値の設定
    _companyName = widget.initialData['company_name'] ?? '';
    _personInCharge = widget.initialData['person_in_charge'] ?? '';
    _email = widget.initialData['person_email'] ?? '';
    _phone = widget.initialData['person_phone'] ?? '';
    _address = widget.initialData['address'] ?? '';

    // エンド企業・中間請け企業固有のフィールド
    _department = widget.initialData['department'] ?? '';
    _position = widget.initialData['position'] ?? '';

    // 中間請け企業固有のフィールド
    _commission = widget.initialData['commission'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('中間請け企業編集'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 共通フィールド
              _buildCommonFields(),

              // 中間請け企業固有のフィールド
              ..._buildIntermediaryCompanyFields(),

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

  // 中間請け企業固有のフィールドを構築
  List<Widget> _buildIntermediaryCompanyFields() {
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
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: '手数料',
          hintText: '例：10%',
          filled: true,
        ),
        initialValue: _commission,
        onSaved: (value) {
          _commission = value ?? '';
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
      'companyType': CompanyType.intermediary.name,
      'department': _department,
      'position': _position,
      'commission': _commission,
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
