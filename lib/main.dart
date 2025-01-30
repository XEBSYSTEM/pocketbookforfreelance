import 'package:flutter/material.dart';

void main() {
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
              Tab(icon: Icon(Icons.home), text: 'ホーム'),
              Tab(icon: Icon(Icons.business), text: '仕事'),
              Tab(icon: Icon(Icons.school), text: '学習'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('ホーム画面')),
            Center(child: Text('仕事画面')),
            Center(child: Text('学習画面')),
          ],
        ),
      ),
    );
  }
}
