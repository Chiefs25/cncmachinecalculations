import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/screens/login_screen.dart';
import 'package:cncmachinecalculations/screens/home_screen.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CNC Machine Calculations',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _getLoggedInUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(email: snapshot.data!['email']); // Pass email
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _getLoggedInUser() async {
    // Get last logged-in user from DB
    return await DatabaseHelper.instance.getLoggedInUser(
      "some_email@example.com",
    );
  }
}
