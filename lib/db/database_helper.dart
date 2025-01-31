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

    print('Database Path: $path'); // デバッグ用にパスを出力

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 企業種別マスタテーブル
    await db.execute('''
      CREATE TABLE company_types (
        id INTEGER PRIMARY KEY,
        type_name TEXT NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 企業テーブル（エージェント、エンド企業、中間請け企業を統合）
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY,
        company_type INTEGER NOT NULL,
        FOREIGN KEY (company_type) REFERENCES company_types (id),
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

  // 企業種別マスタの取得
  Future<List<Map<String, dynamic>>> readAllCompanyTypes() async {
    final db = await instance.database;
    return await db.query('company_types', orderBy: 'id ASC');
  }

  // 初期データの投入
  Future<void> insertSampleData() async {
    final db = await instance.database;

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
        'company_type': 1,
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
        'company_type': 1,
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
        'company_type': 1,
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
              'company_type': 2,
              'company_name': 'エンド企業${index + 1}',
              'branch_address': '東京都渋谷区...',
              'branch_phone': '03-xxxx-xxxx',
              'head_office_address': '東京都渋谷区...',
              'head_office_phone': '03-xxxx-xxxx',
              'person_in_charge': '担当者名',
              'person_phone': '03-xxxx-xxxx',
              'person_email': 'test@example.com',
            });

    // 中間請け企業のサンプルデータ
    final intermediaryCompanySamples = List.generate(
        10,
        (index) => {
              'id': 14 + index,
              'company_type': 3,
              'company_name': '中間請け企業${index + 1}',
              'branch_address': '東京都渋谷区...',
              'branch_phone': '03-xxxx-xxxx',
              'head_office_address': '東京都渋谷区...',
              'head_office_phone': '03-xxxx-xxxx',
              'person_in_charge': '担当者名',
              'person_phone': '03-xxxx-xxxx',
              'person_email': 'test@example.com',
            });

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
