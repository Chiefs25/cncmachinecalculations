import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final String email;
  const HistoryScreen({Key? key, required this.email}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> historyFuture;

  @override
  void initState() {
    super.initState();
    historyFuture = fetchHistory();
  }

  /// Fetch user history from the database
  Future<List<Map<String, dynamic>>> fetchHistory() async {
    try {
      return await DatabaseHelper.instance.getUserHistory(widget.email);
    } catch (e) {
      print("Error fetching history: $e");
      return [];
    }
  }

  /// Format timestamp to a readable date & time
  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return "Unknown date";
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return timestamp; // Return raw timestamp if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error fetching history",
                style: TextStyle(fontSize: 18),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No history available", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.blue),
                title: Text(history[index]['action']),
                subtitle: Text(formatTimestamp(history[index]['timestamp'])),
              );
            },
          );
        },
      ),
    );
  }
}
