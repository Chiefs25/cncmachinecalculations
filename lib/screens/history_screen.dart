import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final String email;

  const HistoryScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Center(child: Text('User history for $email')),
    );
  }
}
