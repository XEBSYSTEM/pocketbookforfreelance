import 'package:sqflite/sqflite.dart';
import '../company_detail.dart' show CompanyType;

class CompanyRepository {
  final Database db;

  CompanyRepository(this.db);

  // CompanyTypeをint型に変換するヘルパーメソッド
  int getCompanyTypeId(CompanyType type) {
    switch (type) {
      case CompanyType.agent:
        return 1;
      case CompanyType.end:
        return 2;
      case CompanyType.intermediary:
        return 3;
    }
  }

  // 企業種別マスタの取得
  Future<List<Map<String, dynamic>>> readAllCompanyTypes() async {
    return await db.query('company_types', orderBy: 'id ASC');
  }

  // 企業の作成
  Future<int> createCompany(Map<String, dynamic> company) async {
    try {
      print('Creating company with data: $company'); // デバッグログ

      // company_typeをstring型からint型に変換
      final String companyTypeStr = company['companyType'];
      int companyTypeId;
      switch (companyTypeStr) {
        case 'agent':
          companyTypeId = 1;
          break;
        case 'end':
          companyTypeId = 2;
          break;
        case 'intermediary':
          companyTypeId = 3;
          break;
        default:
          throw Exception('Invalid company type: $companyTypeStr');
      }

      final data = {
        'company_type': companyTypeId,
        'company_name': company['companyName'],
        'branch_address': company['branchAddress'],
        'branch_phone': company['branchPhone'],
        'head_office_address': company['headOfficeAddress'],
        'head_office_phone': company['headOfficePhone'],
        'person_in_charge': company['personInCharge'],
        'person_phone': company['personPhone'],
        'person_email': company['personEmail'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Transformed data for database insert: $data'); // デバッグログ
      return await db.insert('companies', data);
    } catch (e) {
      print('Error creating company: $e'); // エラーログ
      throw Exception('企業の登録に失敗しました: $e');
    }
  }

  // 全企業の取得
  Future<List<Map<String, dynamic>>> readAllCompanies() async {
    return await db.query('companies', orderBy: 'created_at DESC');
  }

  // 企業種別指定での取得
  Future<List<Map<String, dynamic>>> readCompaniesByType(
      CompanyType companyType) async {
    return await db.query(
      'companies',
      where: 'company_type = ?',
      whereArgs: [getCompanyTypeId(companyType)],
      orderBy: 'created_at DESC',
    );
  }

  // 1件の取得
  Future<Map<String, dynamic>?> readCompany(int id) async {
    final maps = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // 更新
  Future<int> updateCompany(int id, Map<String, dynamic> company) async {
    // company_typeをstring型からint型に変換
    final String companyTypeStr = company['companyType'];
    int companyTypeId;
    switch (companyTypeStr) {
      case 'agent':
        companyTypeId = 1;
        break;
      case 'end':
        companyTypeId = 2;
        break;
      case 'intermediary':
        companyTypeId = 3;
        break;
      default:
        throw Exception('Invalid company type: $companyTypeStr');
    }

    final data = {
      'company_type': companyTypeId,
      'company_name': company['companyName'],
      'branch_address': company['branchAddress'],
      'branch_phone': company['branchPhone'],
      'head_office_address': company['headOfficeAddress'],
      'head_office_phone': company['headOfficePhone'],
      'person_in_charge': company['personInCharge'],
      'person_phone': company['personPhone'],
      'person_email': company['personEmail'],
      'updated_at': DateTime.now().toIso8601String(),
    };
    return await db.update(
      'companies',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 削除
  Future<int> deleteCompany(int id) async {
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // サンプルデータの投入
  Future<void> insertSampleData() async {
    // 企業種別マスタの初期データ
    final companyTypes = [
      {
        'id': 1,
        'type_name': 'エージェント',
        'description': '人材紹介会社',
      },
      {
        'id': 2,
        'type_name': 'エンド企業',
        'description': '最終契約企業',
      },
      {
        'id': 3,
        'type_name': '中間請け企業',
        'description': '仲介企業',
      },
    ];

    // エージェントのサンプルデータ
    final agentSamples = [
      {
        'id': 1,
        'company_type': 1, // エージェント
        'company_name': 'テックエージェント株式会社',
        'branch_address': '東京都渋谷区神宮前1-1-1',
        'branch_phone': '03-1234-5678',
        'head_office_address': '東京都千代田区丸の内1-1-1',
        'head_office_phone': '03-8765-4321',
        'person_in_charge': '山田太郎',
        'person_phone': '090-1234-5678',
        'person_email': 'yamada@example.com',
      },
      {
        'id': 2,
        'company_type': 1, // エージェント
        'company_name': 'キャリアパートナーズ株式会社',
        'branch_address': '東京都新宿区新宿2-2-2',
        'branch_phone': '03-2345-6789',
        'head_office_address': '東京都港区六本木2-2-2',
        'head_office_phone': '03-9876-5432',
        'person_in_charge': '鈴木花子',
        'person_phone': '090-2345-6789',
        'person_email': 'suzuki@example.com',
      },
      {
        'id': 3,
        'company_type': 1, // エージェント
        'company_name': 'ITキャリア株式会社',
        'branch_address': '東京都品川区五反田3-3-3',
        'branch_phone': '03-3456-7890',
        'head_office_address': '東京都中央区銀座3-3-3',
        'head_office_phone': '03-0987-6543',
        'person_in_charge': '佐藤次郎',
        'person_phone': '090-3456-7890',
        'person_email': 'sato@example.com',
      },
    ];

    // エンド企業のサンプルデータ
    final endCompanySamples = List.generate(
      10,
      (index) => {
        'id': 4 + index,
        'company_type': 2, // エンド企業
        'company_name': 'エンド企業${index + 1}',
        'branch_address': '東京都渋谷区...',
        'branch_phone': '03-xxxx-xxxx',
        'head_office_address': '東京都渋谷区...',
        'head_office_phone': '03-xxxx-xxxx',
        'person_in_charge': '担当者名',
        'person_phone': '03-xxxx-xxxx',
        'person_email': 'test@example.com',
      },
    );

    // 中間請け企業のサンプルデータ
    final intermediaryCompanySamples = List.generate(
      10,
      (index) => {
        'id': 14 + index,
        'company_type': 3, // 中間請け企業
        'company_name': '中間請け企業${index + 1}',
        'branch_address': '東京都渋谷区...',
        'branch_phone': '03-xxxx-xxxx',
        'head_office_address': '東京都渋谷区...',
        'head_office_phone': '03-xxxx-xxxx',
        'person_in_charge': '担当者名',
        'person_phone': '03-xxxx-xxxx',
        'person_email': 'test@example.com',
      },
    );

    // トランザクション開始
    await db.transaction((txn) async {
      // 既存のデータを削除
      await txn.delete('companies');
      await txn.delete('company_types');

      // 企業種別マスタの初期データを挿入
      for (final type in companyTypes) {
        await txn.insert('company_types', type);
      }

      // サンプルデータの挿入
      for (final company in [
        ...agentSamples,
        ...endCompanySamples,
        ...intermediaryCompanySamples
      ]) {
        await txn.insert('companies', company);
      }
    });
  }
}
