import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';

class MyDetailsScreen extends StatefulWidget {
  final String email;

  const MyDetailsScreen({super.key, required this.email});

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    var user = await DatabaseHelper.instance.getLoggedInUser(widget.email);
    if (user != null) {
      setState(() {
        nameController.text = user['name'];
      });
    }
  }

  void _updateDetails() async {
    // For now, just show a message. Implement DB update logic if needed.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User details updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateDetails,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
