import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'tabs/company_list_tab.dart';
import 'tabs/schedule_tab.dart';
import 'tabs/memo_tab.dart';
import 'db/database_helper.dart';

void main() async {
  // Flutter初期化
  WidgetsFlutterBinding.ensureInitialized();

  // プラットフォーム固有のSQLite初期化
  if (Platform.isAndroid) {
    // Androidの場合、システムのSQLiteを使用
    databaseFactory = databaseFactoryFfi;
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // デスクトッププラットフォームの場合
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    // その他のプラットフォーム（Windows, macOS）
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // データベースの初期化
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.grey),
        ),
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
              Tab(icon: Icon(Icons.edit), text: 'メモ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const ScheduleTab(),
            CompanyListTab(),
            const MemoTab(),
          ],
        ),
      ),
    );
  }
}
