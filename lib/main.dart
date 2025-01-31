import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'tabs/company_list_tab.dart';
import 'tabs/schedule_tab.dart';
import 'db/database_helper.dart';

void main() async {
  // Flutter初期化
  WidgetsFlutterBinding.ensureInitialized();

  // WindowsでSQLiteを使用するための初期化
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // データベースの初期化とパスの確認
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('タブアプリ'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'スケジュール'),
              Tab(icon: Icon(Icons.business), text: '企業一覧'),
              Tab(icon: Icon(Icons.school), text: '学習'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const ScheduleTab(),
            CompanyListTab(),
            const Center(child: Text('学習画面')),
          ],
        ),
      ),
    );
  }
}
