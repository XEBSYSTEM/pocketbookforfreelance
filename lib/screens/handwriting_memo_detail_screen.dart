import 'package:flutter/material.dart';
import 'dart:typed_data';

class HandwritingMemoDetailScreen extends StatelessWidget {
  final Uint8List memoData;
  final DateTime createdAt;

  const HandwritingMemoDetailScreen({
    super.key,
    required this.memoData,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(createdAt.toLocal().toString().split('.')[0]),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(
            memoData,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
