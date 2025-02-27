import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CNC Machine Calculations',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Start with LoginScreen
    );
  }
}
