import 'package:flutter/material.dart';
import '../company_form.dart';
import '../agent_detail.dart';
import '../end_company_detail.dart';
import '../intermediary_company_detail.dart';
import '../db/database_helper.dart';

class CompanyListTab extends StatefulWidget {
  const CompanyListTab({super.key});

  @override
  State<CompanyListTab> createState() => _CompanyListTabState();
}

class _CompanyListTabState extends State<CompanyListTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _agentList = [];
  List<Map<String, dynamic>> _endCompanyList = [];
  List<Map<String, dynamic>> _intermediaryList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);

    try {
      _agentList = await _dbHelper.readCompaniesByType('agent');
      _endCompanyList = await _dbHelper.readCompaniesByType('end');
      _intermediaryList = await _dbHelper.readCompaniesByType('intermediary');
    } catch (e) {
      debugPrint('データ取得エラー: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // エージェントリスト
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'エージェント',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 200,
                      child: _agentList.isEmpty
                          ? const Center(child: Text('エージェントが登録されていません'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _agentList.length,
                              itemBuilder: (context, index) {
                                final agent = _agentList[index];
                                return ListTile(
                                  leading: const Icon(Icons.business_center),
                                  title: Text(agent['company_name']),
                                  subtitle: Text(
                                      '担当者: ${agent['person_in_charge'] ?? '未設定'}'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AgentDetail(agentData: agent),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyForm(
                          title: 'エージェント登録',
                          companyType: 1,
                        ),
                      ),
                    );
                    if (result != null) {
                      // TODO: 登録されたエージェントデータを保存
                      print('新しいエージェント: $result');
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('エージェントを追加'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // エンド企業リスト
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'エンド企業',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 200,
                      child: _endCompanyList.isEmpty
                          ? const Center(child: Text('エンド企業が登録されていません'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _endCompanyList.length,
                              itemBuilder: (context, index) {
                                final company = _endCompanyList[index];
                                return ListTile(
                                  leading: const Icon(Icons.apartment),
                                  title: Text(company['company_name']),
                                  subtitle: Text(
                                      '担当者: ${company['person_in_charge'] ?? '未設定'}'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    // TODO: 実際のデータを渡すように修正
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EndCompanyDetail(
                                          endCompanyData: {
                                            'companyName': 'エンド企業${index + 1}',
                                            'address': '東京都渋谷区...',
                                            'phone': '03-xxxx-xxxx',
                                            'personInCharge': '担当者名',
                                            'department': '人事部',
                                            'position': '部長',
                                            'email': 'test@example.com',
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyForm(
                          title: 'エンド企業登録',
                          companyType: 2,
                        ),
                      ),
                    );
                    if (result != null) {
                      // TODO: 登録されたエンド企業データを保存
                      print('新しいエンド企業: $result');
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('エンド企業を追加'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 中間請け企業リスト
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '中間請け企業',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 200,
                      child: _intermediaryList.isEmpty
                          ? const Center(child: Text('中間請け企業が登録されていません'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _intermediaryList.length,
                              itemBuilder: (context, index) {
                                final company = _intermediaryList[index];
                                return ListTile(
                                  leading: const Icon(Icons.business),
                                  title: Text(company['company_name']),
                                  subtitle: Text(
                                      '担当者: ${company['person_in_charge'] ?? '未設定'}'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    // TODO: 実際のデータを渡すように修正
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            IntermediaryCompanyDetail(
                                          intermediaryCompanyData: {
                                            'companyName': '中間請け企業${index + 1}',
                                            'address': '東京都渋谷区...',
                                            'phone': '03-xxxx-xxxx',
                                            'personInCharge': '担当者名',
                                            'department': '営業部',
                                            'position': '部長',
                                            'email': 'test@example.com',
                                            'commission': '10%',
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyForm(
                          title: '中間請け企業登録',
                          companyType: 3,
                        ),
                      ),
                    );
                    if (result != null) {
                      // TODO: 登録された中間請け企業データを保存
                      print('新しい中間請け企業: $result');
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('中間請け企業を追加'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
