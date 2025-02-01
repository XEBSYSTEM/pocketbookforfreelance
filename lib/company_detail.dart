import 'package:flutter/material.dart';
import 'company_edit.dart';
import 'db/database_helper.dart';

enum CompanyType {
  agent,
  end,
  intermediary,
}

class CompanyDetail extends StatefulWidget {
  final int companyId;
  final CompanyType companyType;

  const CompanyDetail({
    super.key,
    required this.companyId,
    required this.companyType,
  });

  @override
  State<CompanyDetail> createState() => _CompanyDetailState();
}

class _CompanyDetailState extends State<CompanyDetail> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Map<String, dynamic>? _companyData;
  bool _isLoading = true;

  String get _companyTypeText {
    switch (widget.companyType) {
      case CompanyType.agent:
        return 'エージェント';
      case CompanyType.end:
        return 'エンド企業';
      case CompanyType.intermediary:
        return '仲介企業';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      final data = await _dbHelper.readCompany(widget.companyId);
      setState(() {
        _companyData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('${_companyTypeText}データの取得に失敗: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: data.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInfoSections() {
    final sections = <Widget>[];

    // エージェントの場合のみ支社情報を表示
    if (widget.companyType == CompanyType.agent) {
      sections.add(
        _buildInfoSection(
          '支社情報',
          {
            '住所': _companyData!['branch_address'] ?? '未設定',
            '電話番号': _companyData!['branch_phone'] ?? '未設定',
          },
        ),
      );
      sections.add(const SizedBox(height: 16));
    }

    // 企業/本社情報セクション
    sections.add(
      _buildInfoSection(
        widget.companyType == CompanyType.agent ? '本社情報' : '企業情報',
        {
          '所在地': _companyData!['head_office_address'] ?? '未設定',
          '電話番号': _companyData!['head_office_phone'] ?? '未設定',
        },
      ),
    );
    sections.add(const SizedBox(height: 16));

    // 担当者情報セクション
    sections.add(
      _buildInfoSection(
        '担当者情報',
        {
          '名前': _companyData!['person_in_charge'] ?? '未設定',
          '電話番号': _companyData!['person_phone'] ?? '未設定',
          'メール': _companyData!['person_email'] ?? '未設定',
        },
      ),
    );

    return sections;
  }

  Widget _buildEditButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading || _companyData == null
          ? null
          : () async {
              final editScreen = CompanyEdit(
                companyId: widget.companyId,
                initialData: _companyData!,
                initialCompanyType: widget.companyType,
              );

              final isUpdated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => editScreen,
                ),
              );

              if (isUpdated == true) {
                // データを再読み込み
                await _loadCompanyData();
              }
            },
      icon: const Icon(Icons.edit),
      label: const Text('編集'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${_companyTypeText}の削除'),
            content: Text('この${_companyTypeText}を削除してもよろしいですか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _dbHelper.deleteCompany(widget.companyId);
                    if (!mounted) return;
                    Navigator.of(context).pop(); // ダイアログを閉じる
                    Navigator.of(context).pop(); // 詳細画面を閉じる
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_companyTypeText}を削除しました'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.of(context).pop(); // ダイアログを閉じる
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('削除に失敗しました: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  '削除',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.delete),
      label: const Text('削除'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_companyTypeText}詳細'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _companyData == null
              ? Center(child: Text('${_companyTypeText}が見つかりません'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _companyData!['company_name'] ?? '企業名未設定',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_companyData!['person_in_charge']?.isNotEmpty ==
                                true)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '担当: ${_companyData!['person_in_charge']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildInfoSections(),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: _buildEditButton()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDeleteButton()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
