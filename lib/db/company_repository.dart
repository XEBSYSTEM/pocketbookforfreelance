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
}
