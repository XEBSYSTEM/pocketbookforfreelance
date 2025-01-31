import 'package:flutter/material.dart';
import 'agent_edit.dart';
import 'db/database_helper.dart';

class AgentDetail extends StatefulWidget {
  final int agentId;

  const AgentDetail({super.key, required this.agentId});

  @override
  State<AgentDetail> createState() => _AgentDetailState();
}

class _AgentDetailState extends State<AgentDetail> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Map<String, dynamic>? _agentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    try {
      final data = await _dbHelper.readCompany(widget.agentId);
      setState(() {
        _agentData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('エージェントデータの取得に失敗: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エージェント詳細'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agentData == null
              ? const Center(child: Text('エージェントが見つかりません'))
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
                              _agentData!['company_name'] ?? '企業名未設定',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_agentData!['person_in_charge']?.isNotEmpty ==
                                true)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '担当: ${_agentData!['person_in_charge']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        '支社情報',
                        {
                          '住所': _agentData!['branch_address'] ?? '未設定',
                          '電話番号': _agentData!['branch_phone'] ?? '未設定',
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        '本社情報',
                        {
                          '住所': _agentData!['head_office_address'] ?? '未設定',
                          '電話番号': _agentData!['head_office_phone'] ?? '未設定',
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        '担当者情報',
                        {
                          '名前': _agentData!['person_in_charge'] ?? '未設定',
                          '電話番号': _agentData!['person_phone'] ?? '未設定',
                          'メール': _agentData!['person_email'] ?? '未設定',
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
                                  final updatedData = await Navigator.push<
                                      Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AgentEdit(
                                        agentId: widget.agentId,
                                        initialData: _agentData!,
                                      ),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
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
                                      title: const Text('エージェントの削除'),
                                      content:
                                          const Text('このエージェントを削除してもよろしいですか？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
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
