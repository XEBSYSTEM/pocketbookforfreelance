import 'package:flutter/material.dart';
import '../company_form.dart';
import '../agent_detail.dart';
import '../end_company_detail.dart';
import '../intermediary_company_detail.dart';

class CompanyListTab extends StatelessWidget {
  CompanyListTab({super.key});

  // サンプルデータ
  final List<Map<String, dynamic>> _agentList = [
    {
      'companyName': 'テックエージェント株式会社',
      'branchAddress': '東京都渋谷区神宮前1-1-1',
      'branchPhone': '03-1234-5678',
      'headOfficeAddress': '東京都千代田区丸の内1-1-1',
      'headOfficePhone': '03-8765-4321',
      'personInCharge': '山田太郎',
      'personPhone': '090-1234-5678',
      'personEmail': 'yamada@example.com',
    },
    {
      'companyName': 'キャリアパートナーズ株式会社',
      'branchAddress': '東京都新宿区新宿2-2-2',
      'branchPhone': '03-2345-6789',
      'headOfficeAddress': '東京都港区六本木2-2-2',
      'headOfficePhone': '03-9876-5432',
      'personInCharge': '鈴木花子',
      'personPhone': '090-2345-6789',
      'personEmail': 'suzuki@example.com',
    },
    {
      'companyName': 'ITキャリア株式会社',
      'branchAddress': '東京都品川区五反田3-3-3',
      'branchPhone': '03-3456-7890',
      'headOfficeAddress': '東京都中央区銀座3-3-3',
      'headOfficePhone': '03-0987-6543',
      'personInCharge': '佐藤次郎',
      'personPhone': '090-3456-7890',
      'personEmail': 'sato@example.com',
    },
  ];

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
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _agentList.length,
                  itemBuilder: (context, index) {
                    final agent = _agentList[index];
                    return ListTile(
                      leading: const Icon(Icons.business_center),
                      title: Text(agent['companyName']),
                      subtitle: Text('担当者: ${agent['personInCharge']}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgentDetail(agentData: agent),
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
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.apartment),
                      title: Text('エンド企業${index + 1}'),
                      subtitle: Text('業種: IT・通信${index + 1}'),
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
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.business),
                      title: Text('中間請け企業${index + 1}'),
                      subtitle: Text('所在地: 東京都${index + 1}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: 実際のデータを渡すように修正
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IntermediaryCompanyDetail(
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
