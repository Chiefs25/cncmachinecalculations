import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/screens/login_screen.dart';
import 'package:cncmachinecalculations/screens/register_screen.dart';
import 'package:cncmachinecalculations/screens/home_screen.dart';
import 'package:cncmachinecalculations/screens/history_screen.dart';
import 'package:cncmachinecalculations/screens/my_details_screen.dart';
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(email: snapshot.data!['email']);
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register':
            (context) => const RegisterScreen(), // Added Register Screen Route
        '/home':
            (context) => _buildScreen(
              context,
              (args) => HomeScreen(email: args?['email'] ?? ''),
            ),
        '/myDetails':
            (context) => _buildScreen(
              context,
              (args) => MyDetailsScreen(email: args?['email'] ?? ''),
            ),
        '/history':
            (context) => _buildScreen(
              context,
              (args) => HistoryScreen(email: args?['email'] ?? ''),
            ),
      },
    );
  }

  /// Fetch logged-in user details from the database
  Future<Map<String, dynamic>?> _getLoggedInUser() async {
    return await DatabaseHelper.instance.getLoggedInUser(
      "some_email@example.com",
    );
  }

  /// Helper function to handle route arguments safely
  Widget _buildScreen(
    BuildContext context,
    Widget Function(Map<String, dynamic>?) builder,
  ) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return builder(args);
  }
}
