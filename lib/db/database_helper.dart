import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../company_detail.dart' show CompanyType;
import 'company_repository.dart';
import 'schedule_repository.dart';
import 'database_migration.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  CompanyRepository? _companyRepository;
  ScheduleRepository? _scheduleRepository;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pocketbook.sqlite3');
    _companyRepository = CompanyRepository(_database!);
    _scheduleRepository = ScheduleRepository(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    print('Current Directory: ${Directory.current.path}');
    print('Database Directory: $dbPath');
    print('Database File: $filePath');

    final path = join(dbPath, filePath);
    print('Full Database Path: $path');

    // ファイルの存在確認とログ出力
    final file = File(path);
    if (file.existsSync()) {
      print('Database file exists at: $path');
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
      version: 6,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await DatabaseMigration.migrate(db, 0, version);
  }

  // データベースを閉じる
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Company Repository Methods
  Future<int> createCompany(Map<String, dynamic> company) async {
    final db = await database;
    return await _companyRepository!.createCompany(company);
  }

  Future<List<Map<String, dynamic>>> readAllCompanies() async {
    final db = await database;
    return await _companyRepository!.readAllCompanies();
  }

  Future<List<Map<String, dynamic>>> readAllCompanyTypes() async {
    final db = await database;
    return await _companyRepository!.readAllCompanyTypes();
  }

  Future<List<Map<String, dynamic>>> readCompaniesByType(
      CompanyType companyType) async {
    final db = await database;
    return await _companyRepository!.readCompaniesByType(companyType);
  }

  Future<Map<String, dynamic>?> readCompany(int id) async {
    final db = await database;
    return await _companyRepository!.readCompany(id);
  }

  Future<int> updateCompany(int id, Map<String, dynamic> company) async {
    final db = await database;
    return await _companyRepository!.updateCompany(id, company);
  }

  Future<int> deleteCompany(int id) async {
    final db = await database;
    return await _companyRepository!.deleteCompany(id);
  }

  // Schedule Repository Methods
  Future<int> createSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    return await _scheduleRepository!.createSchedule(schedule);
  }

  Future<List<Map<String, dynamic>>> readSchedulesByDate(DateTime date) async {
    final db = await database;
    return await _scheduleRepository!.readSchedulesByDate(date);
  }

  Future<Map<String, dynamic>?> readSchedule(int id) async {
    final db = await database;
    return await _scheduleRepository!.readSchedule(id);
  }

  Future<int> updateSchedule(int id, Map<String, dynamic> schedule) async {
    final db = await database;
    return await _scheduleRepository!.updateSchedule(id, schedule);
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await _scheduleRepository!.deleteSchedule(id);
  }
}
