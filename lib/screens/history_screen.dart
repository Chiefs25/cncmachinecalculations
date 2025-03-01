import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  final String email;

  const HistoryScreen({super.key, required this.email});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.getUserHistory(widget.email);
    setState(() {
      history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isEmpty
          ? const Center(child: Text('No history found'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  title: Text(item['action']),
                  subtitle: Text(item['timestamp']),
                );
              },
            ),
    );
  }
}
