import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController sectionController =
      TextEditingController(); // ✅ Added Section Controller

  void _register() async {
    String name = nameController.text.trim();
    String regNo = regNoController.text.trim();
    String section = sectionController.text.trim(); // ✅ Added Section
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (name.isEmpty ||
        regNo.isEmpty ||
        section.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    if (!RegExp(
      r"^[a-zA-Z0-9._%+-]+@(gmail\.com|christuniversity\.in)$",
    ).hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid email domain')));
      return;
    }

    if (!RegExp(
      r"^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\\$%^&*]).{6,}$",
    ).hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must contain A-Z, 0-9, and a special character',
          ),
        ),
      );
      return;
    }

    bool exists = await DatabaseHelper.instance.userExists(email);
    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User already registered.')));
      return;
    }

    await DatabaseHelper.instance.insertUser(
      name,
      regNo,
      email,
      password,
      section,
      'password',
    ); // ✅ Added Section

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registration Successful!')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: regNoController,
              decoration: const InputDecoration(
                labelText: 'Registration Number',
              ),
            ),
            TextField(
              controller: sectionController, // ✅ Section Input
              decoration: const InputDecoration(labelText: 'Section'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
