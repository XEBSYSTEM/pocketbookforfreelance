import 'package:flutter/material.dart';
import 'end_company_edit.dart';

class EndCompanyDetail extends StatelessWidget {
  final Map<String, dynamic> endCompanyData;

  const EndCompanyDetail({super.key, required this.endCompanyData});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エンド企業詳細'),
      ),
      body: SingleChildScrollView(
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
                    endCompanyData['companyName'] ?? '企業名未設定',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (endCompanyData['personInCharge']?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '担当: ${endCompanyData['personInCharge']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              '会社情報',
              {
                '住所': endCompanyData['address'] ?? '未設定',
                '電話番号': endCompanyData['phone'] ?? '未設定',
              },
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              '担当者情報',
              {
                '名前': endCompanyData['personInCharge'] ?? '未設定',
                '部署': endCompanyData['department'] ?? '未設定',
                '役職': endCompanyData['position'] ?? '未設定',
                'メール': endCompanyData['email'] ?? '未設定',
              },
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final updatedData =
                            await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EndCompanyEdit(endCompanyData: endCompanyData),
                          ),
                        );

                        if (updatedData != null) {
                          Navigator.pop(context, updatedData);
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('編集'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('エンド企業の削除'),
                            content: const Text('このエンド企業を削除してもよろしいですか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: 削除処理の実装
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
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
                    ),
                  ),
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
