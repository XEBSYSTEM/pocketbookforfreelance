import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pocketbook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 企業テーブル（エージェント、エンド企業、中間請け企業を統合）
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY,
        company_type INTEGER NOT NULL CHECK (company_type IN (1, 2, 3)), -- 1:エージェント, 2:エンド企業, 3:中間請け企業
        company_name TEXT NOT NULL,
        branch_address TEXT,
        branch_phone TEXT,
        head_office_address TEXT,
        head_office_phone TEXT,
        person_in_charge TEXT,
        person_phone TEXT,
        person_email TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // スケジュールテーブル（company_idの参照先をcompaniesテーブルに変更）
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date DATETIME NOT NULL,
        company_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (company_id) REFERENCES companies (id)
      )
    ''');
  }

  // データベースを閉じる
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // 企業のCRUD操作
  // 作成
  Future<int> createCompany(Map<String, dynamic> company) async {
    final db = await instance.database;
    final data = {
      'company_type': company['companyType'],
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
    return await db.insert('companies', data);
  }

  // 読み取り（全企業）
  Future<List<Map<String, dynamic>>> readAllCompanies() async {
    final db = await instance.database;
    return await db.query('companies', orderBy: 'created_at DESC');
  }

  // 読み取り（企業種別指定）
  Future<List<Map<String, dynamic>>> readCompaniesByType(
      int companyType) async {
    final db = await instance.database;
    return await db.query(
      'companies',
      where: 'company_type = ?',
      whereArgs: [companyType],
      orderBy: 'created_at DESC',
    );
  }

  // 読み取り（1件）
  Future<Map<String, dynamic>?> readCompany(int id) async {
    final db = await instance.database;
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
    final db = await instance.database;
    final data = {
      'company_type': company['companyType'],
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
    final db = await instance.database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
