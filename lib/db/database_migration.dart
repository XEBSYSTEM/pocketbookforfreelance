import 'package:sqflite/sqflite.dart';

class DatabaseMigration {
  static Future<void> migrate(
      Database db, int oldVersion, int newVersion) async {
    // 最新バージョンに達するまで順番にマイグレーションを実行
    if (oldVersion < 1) {
      await _createInitialTables(db);
    }

    if (oldVersion < 5) {
      await _migrateToVersion5(db);
    }
  }

  static Future<void> _createInitialTables(Database db) async {
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

    // 企業種別マスタの初期データを挿入
    await db.execute('''
      INSERT INTO company_types (id, type_name, description) VALUES
      (1, 'エージェント', '人材紹介会社'),
      (2, 'エンド企業', '最終契約企業'),
      (3, '中間請け企業', '仲介企業')
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

  static Future<void> _migrateToVersion5(Database db) async {
    // バックアップテーブルの作成（schedulesテーブルが存在する場合のみ）
    final tables = await db.query('sqlite_master',
        where: 'type = ? AND name = ?', whereArgs: ['table', 'schedules']);

    if (tables.isNotEmpty) {
      await db
          .execute('CREATE TABLE schedules_backup AS SELECT * FROM schedules');

      // 既存のテーブルを削除
      await db.execute('DROP TABLE IF EXISTS schedules');

      // 新しいスキーマでテーブルを再作成
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
