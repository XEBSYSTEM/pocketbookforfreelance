import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    // アプリのドキュメントディレクトリを取得
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocDir.path, 'databases');

    // データベースディレクトリが存在しない場合は作成
    final dir = Directory(dbPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
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
