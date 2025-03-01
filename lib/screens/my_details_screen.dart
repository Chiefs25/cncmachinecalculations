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
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    var user = await DatabaseHelper.instance.getLoggedInUser(widget.email);
    if (user != null) {
      setState(() {
        nameController.text = user['name'] ?? '';
        regNoController.text = user['regno'] ?? '';
        sectionController.text = user['section'] ?? '';
      });
    } else {
      print("❌ User not found in database: ${widget.email}");
    }
  }

  Future<void> _updateDetails() async {
    String newName = nameController.text.trim();
    String newRegNo = regNoController.text.trim();
    String newSection = sectionController.text.trim();

    if (newName.isEmpty || newRegNo.isEmpty || newSection.isEmpty) {
      _showSnackBar('Fields cannot be empty!');
      return;
    }

    // ✅ Ensure the user exists before updating
    var user = await DatabaseHelper.instance.getLoggedInUser(widget.email);
    if (user == null) {
      _showSnackBar('User not found! Please register first.');
      return;
    }

    int result = await DatabaseHelper.instance.updateUserDetails(
      widget.email,
      newName,
      newRegNo,
      newSection,
    );

    if (result > 0) {
      _showSnackBar('User details updated successfully!');
    } else {
      _showSnackBar('Failed to update details!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            const SizedBox(height: 10),
            TextField(
              controller: regNoController,
              decoration: const InputDecoration(
                labelText: 'Registration Number',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(labelText: 'Section'),
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
