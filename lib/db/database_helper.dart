import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../company_detail.dart' show CompanyType;
import '../models/schedule_form_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pocketbook.sqlite3');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    print('Current Directory: ${Directory.current.path}');
    print('Database Directory: $dbPath');
    print('Database File: $filePath');

    final path = join(dbPath, filePath);
    print('Full Database Path: $path');

    // ファイルの存在確認
    final file = File(path);
    if (file.existsSync()) {
      print('Database file exists at: $path');
      await file.delete();
      print('Existing database file deleted');
    }

    // ディレクトリが存在することを確認
    final dir = Directory(dbPath);
    print('Directory exists: ${dir.existsSync()}');
    if (!dir.existsSync()) {
      print('Creating directory: $dbPath');
      dir.createSync(recursive: true);
    }

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _migrate(db, 0, version);
  }

  Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    // 最新バージョンに達するまで順番にマイグレーションを実行
    if (oldVersion < 1) {
      await _createInitialTables(db);
    }

    if (oldVersion < 5) {
      // バックアップテーブルの作成（schedulesテーブルが存在する場合のみ）
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'schedules']);

      if (tables.isNotEmpty) {
        await db.execute(
            'CREATE TABLE schedules_backup AS SELECT * FROM schedules');

        // 既存のテーブルを削除
        await db.execute('DROP TABLE IF EXISTS schedules');

        // 新しいスキーマでテーブルを再作成
        // スケジュールテーブル
        await db.execute('''
        CREATE TABLE schedules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          date DATE NOT NULL,
          is_all_day BOOLEAN NOT NULL DEFAULT 0,
          start_time TEXT,
          end_time TEXT,
          meeting_type TEXT,
          url TEXT,
          agent_id INTEGER,
          end_company_id INTEGER,
          memo TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (agent_id) REFERENCES companies (id),
          FOREIGN KEY (end_company_id) REFERENCES companies (id)
        )
      ''');

        // バックアップからデータを移行（日付のみを保持）
        await db.execute('''
        INSERT INTO schedules 
        SELECT 
          id,
          title,
          DATE(date),
          is_all_day,
          start_time,
          end_time,
          meeting_type,
          url,
          agent_id,
          end_company_id,
          memo,
          created_at,
          updated_at
        FROM schedules_backup
      ''');

        // バックアップテーブルを削除
        await db.execute('DROP TABLE IF EXISTS schedules_backup');
      } else {
        // schedulesテーブルが存在しない場合は新規作成
        await db.execute('''
          CREATE TABLE schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date DATE NOT NULL,
            is_all_day BOOLEAN NOT NULL DEFAULT 0,
            start_time TEXT,
            end_time TEXT,
            meeting_type TEXT,
            url TEXT,
            agent_id INTEGER,
            end_company_id INTEGER,
            memo TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (agent_id) REFERENCES companies (id),
            FOREIGN KEY (end_company_id) REFERENCES companies (id)
          )
        ''');
      }
    }
  }

  Future<void> _createInitialTables(Database db) async {
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
        company_name TEXT NOT NULL,
        branch_address TEXT,
        branch_phone TEXT,
        head_office_address TEXT,
        head_office_phone TEXT,
        person_in_charge TEXT,
        person_phone TEXT,
        person_email TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (company_type) REFERENCES company_types(id)
      )
    ''');

    // スケジュールテーブル
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date DATE NOT NULL,
        is_all_day BOOLEAN NOT NULL DEFAULT 0,
        start_time TEXT,
        end_time TEXT,
        meeting_type TEXT,
        url TEXT,
        agent_id INTEGER,
        end_company_id INTEGER,
        memo TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (agent_id) REFERENCES companies (id),
        FOREIGN KEY (end_company_id) REFERENCES companies (id)
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
    try {
      final db = await instance.database;
      print('Creating company with data: $company'); // デバッグログ

      // company_typeをstring型からint型に変換
      final String companyTypeStr = company['companyType'];
      int companyTypeId;
      switch (companyTypeStr) {
        case 'agent':
          companyTypeId = 1;
        case 'end':
          companyTypeId = 2;
        case 'intermediary':
          companyTypeId = 3;
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

      print('Transformed data for database insert: $data'); // デバッグログ追加

      print('Transformed data for insert: $data'); // デバッグログ
      return await db.insert('companies', data);
    } catch (e) {
      print('Error creating company: $e'); // エラーログ
      throw Exception('企業の登録に失敗しました: $e');
    }
  }

  // 読み取り（全企業）
  Future<List<Map<String, dynamic>>> readAllCompanies() async {
    final db = await instance.database;
    return await db.query('companies', orderBy: 'created_at DESC');
  }

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

  // 読み取り（企業種別指定）
  Future<List<Map<String, dynamic>>> readCompaniesByType(
      CompanyType companyType) async {
    final db = await instance.database;
    return await db.query(
      'companies',
      where: 'company_type = ?',
      whereArgs: [getCompanyTypeId(companyType)],
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
    // company_typeをstring型からint型に変換
    final String companyTypeStr = company['companyType'];
    int companyTypeId;
    switch (companyTypeStr) {
      case 'agent':
        companyTypeId = 1;
      case 'end':
        companyTypeId = 2;
      case 'intermediary':
        companyTypeId = 3;
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
    final db = await instance.database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // スケジュールのCRUD操作
  // 作成
  Future<int> createSchedule(Map<String, dynamic> schedule) async {
    try {
      final db = await instance.database;

      // ScheduleFormDataを使用してデータを変換
      final formData = ScheduleFormData.fromMap(schedule);
      final mappedData = formData.toMap();

      final data = {
        ...mappedData,
        'is_all_day': mappedData['isAllDay'] ? 1 : 0,
        'agent_id': mappedData['agent'],
        'end_company_id': mappedData['endCompany'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await db.insert('schedules', data);
    } catch (e) {
      print('Error creating schedule: $e');
      throw Exception('スケジュールの登録に失敗しました: $e');
    }
  }

  // 読み取り（日付指定）
  Future<List<Map<String, dynamic>>> readSchedulesByDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final nextDateStr =
        DateTime(date.year, date.month, date.day + 1).toIso8601String();

    return await db.query(
      'schedules',
      where: 'date >= ? AND date < ?',
      whereArgs: [dateStr, nextDateStr],
      orderBy: 'start_time ASC',
    );
  }

  // 読み取り（1件）
  Future<Map<String, dynamic>?> readSchedule(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'schedules',
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
  Future<int> updateSchedule(int id, Map<String, dynamic> schedule) async {
    try {
      final db = await instance.database;

      // ScheduleFormDataを使用してデータを変換
      final formData = ScheduleFormData.fromMap(schedule);
      final mappedData = formData.toMap();

      final data = {
        ...mappedData,
        'is_all_day': mappedData['isAllDay'] ? 1 : 0,
        'agent_id': mappedData['agent'],
        'end_company_id': mappedData['endCompany'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await db.update(
        'schedules',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating schedule: $e');
      throw Exception('スケジュールの更新に失敗しました: $e');
    }
  }

  // 削除
  Future<int> deleteSchedule(int id) async {
    final db = await instance.database;
    return await db.delete(
      'schedules',
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
            });

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
