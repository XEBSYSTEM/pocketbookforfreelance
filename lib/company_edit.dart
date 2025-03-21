import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'company_detail.dart';

class CompanyEdit extends StatefulWidget {
  final int companyId;
  final Map<String, dynamic> initialData;
  final CompanyType initialCompanyType;

  const CompanyEdit({
    super.key,
    required this.companyId,
    required this.initialData,
    required this.initialCompanyType,
  });

  @override
  State<CompanyEdit> createState() => _CompanyEditState();
}

class _CompanyEditState extends State<CompanyEdit> {
  final _formKey = GlobalKey<FormState>();

  // 共通フィールド
  late String _companyName;
  late String _personInCharge;
  late String _email;
  late String _phone;
  late String _address;

  // エージェント固有のフィールド
  late String _branchAddress;
  late String _branchPhone;
  late String _headOfficeAddress;
  late String _headOfficePhone;

  // エンド企業・中間請け企業固有のフィールド
  late String _department;
  late String _position;

  // 中間請け企業固有のフィールド
  late String _commission;

  late CompanyType _companyType;

  @override
  void initState() {
    super.initState();
    // 初期値の設定
    _companyType = widget.initialCompanyType;
    _companyName = widget.initialData['company_name'] ?? '';
    _personInCharge = widget.initialData['person_in_charge'] ?? '';
    _email = widget.initialData['person_email'] ?? '';
    _phone = widget.initialData['person_phone'] ?? '';
    _address = widget.initialData['address'] ?? '';

    // エージェント固有のフィールド
    _branchAddress = widget.initialData['branch_address'] ?? '';
    _branchPhone = widget.initialData['branch_phone'] ?? '';
    _headOfficeAddress = widget.initialData['head_office_address'] ?? '';
    _headOfficePhone = widget.initialData['head_office_phone'] ?? '';

    // エンド企業・中間請け企業固有のフィールド
    _department = widget.initialData['department'] ?? '';
    _position = widget.initialData['position'] ?? '';

    // 中間請け企業固有のフィールド
    _commission = widget.initialData['commission'] ?? '';
  }

  String _getTitle() {
    switch (_companyType) {
      case CompanyType.end:
        return 'エンド企業編集';
      case CompanyType.intermediary:
        return '中間請け企業編集';
      case CompanyType.agent:
        return 'エージェント編集';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: Column(
        children: [
          // 企業タイプ選択
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<CompanyType>(
              decoration: const InputDecoration(
                labelText: '企業タイプ',
                filled: true,
              ),
              value: _companyType,
              items: CompanyType.values.map((type) {
                String label;
                switch (type) {
                  case CompanyType.agent:
                    label = 'エージェント';
                  case CompanyType.end:
                    label = 'エンド企業';
                  case CompanyType.intermediary:
                    label = '中間請け企業';
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (CompanyType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _companyType = newValue;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 共通フィールド
                    _buildCommonFields(),

                    // 企業タイプに応じた追加フィールド
                    ..._buildTypeSpecificFields(),

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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('更新する'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  // 企業タイプに応じた追加フィールドを構築
  List<Widget> _buildTypeSpecificFields() {
    final fields = <Widget>[];

    if (_companyType == CompanyType.agent) {
      // エージェント固有のフィールド
      fields.addAll([
        const SizedBox(height: 16),
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
      ]);
    } else {
      // エンド企業・中間請け企業共通のフィールド
      fields.addAll([
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
      ]);

      // 中間請け企業固有のフィールド
      if (_companyType == CompanyType.intermediary) {
        fields.add(
          Column(
            children: [
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
            ],
          ),
        );
      }
    }

    return fields;
  }

  // 更新用のデータを取得（データベースのカラム名に合わせる）
  Map<String, dynamic> _getUpdatedData() {
    final data = {
      'companyName': _companyName,
      'personInCharge': _personInCharge,
      'personEmail': _email,
      'personPhone': _phone,
      'address': _address,
      'companyType': _companyType.name,
    };

    if (_companyType == CompanyType.agent) {
      data.addAll({
        'branchAddress': _branchAddress,
        'branchPhone': _branchPhone,
        'headOfficeAddress': _headOfficeAddress,
        'headOfficePhone': _headOfficePhone,
      });
    } else {
      data.addAll({
        'department': _department,
        'position': _position,
      });

      if (_companyType == CompanyType.intermediary) {
        data['commission'] = _commission;
      }
    }

    return data;
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
