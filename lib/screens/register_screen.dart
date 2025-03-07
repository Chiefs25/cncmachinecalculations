import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _register() async {
    _hideKeyboard();

    if (!_formKey.currentState!.validate()) return;

    String name = nameController.text.trim();
    String regNo = regNoController.text.trim();
    String section = sectionController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;

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
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registration Successful!')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard, // ✅ Dismiss keyboard on outside tap
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: regNoController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'Registration Number is required'
                              : null,
                ),
                TextFormField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section'),
                  validator:
                      (value) => value!.isEmpty ? 'Section is required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) return 'Email is required';
                    if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@(gmail\.com|christuniversity\.in)$",
                    ).hasMatch(value)) {
                      return 'Invalid email domain';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'Password is required';
                    if (!RegExp(
                      r"^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{6,}$",
                    ).hasMatch(value)) {
                      return 'Password must contain A-Z, 0-9, and a special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
