import 'package:flutter/material.dart';
import 'company_detail.dart';
import 'db/database_helper.dart';

class CompanyForm extends StatefulWidget {
  final String title;
  final CompanyType companyType;

  const CompanyForm({
    super.key,
    required this.title,
    required this.companyType,
  });

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
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
        title: Text(widget.title),
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
                    // 企業種別を文字列に変換
                    String companyTypeStr = widget.companyType.name;

                    // フォームの値をデータベースカラム名に合わせてMapにまとめる
                    final companyData = {
                      'companyType': companyTypeStr,
                      'company_name': _companyName,
                      'branch_address': _branchAddress,
                      'branch_phone': _branchPhone,
                      'head_office_address': _headOfficeAddress,
                      'head_office_phone': _headOfficePhone,
                      'person_in_charge': _personInCharge,
                      'person_phone': _personPhone,
                      'person_email': _personEmail,
                    };

                    // データベースに保存
                    try {
                      print('企業データを登録します: $companyData'); // デバッグログ

                      // 企業種別マスタデータの存在確認
                      final companyTypes =
                          await DatabaseHelper.instance.readAllCompanyTypes();
                      if (companyTypes.isEmpty) {
                        print('企業種別マスタデータが存在しないため、初期データを投入します'); // デバッグログ
                        await DatabaseHelper.instance.insertSampleData();
                      }

                      final id = await DatabaseHelper.instance
                          .createCompany(companyData);
                      print('企業データを登録しました。ID: $id'); // デバッグログ

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${_getCompanyTypeName(widget.companyType)}を登録しました'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, companyData);
                      }
                    } catch (e) {
                      print('企業データの登録に失敗しました: $e'); // デバッグログ
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${_getCompanyTypeName(widget.companyType)}の登録に失敗しました: ${e.toString()}'),
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

  String _getCompanyTypeName(CompanyType type) {
    switch (type) {
      case CompanyType.agent:
        return 'エージェント';
      case CompanyType.end:
        return 'エンド企業';
      case CompanyType.intermediary:
        return '中間請け企業';
    }
  }
}
