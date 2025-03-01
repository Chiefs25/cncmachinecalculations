import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/excel_service.dart';
import 'package:cncmachinecalculations/services/calculation_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? fileName;
  String? savedFilePath;
  List<Map<String, double>>? processedData;
  Map<String, dynamic>? leastSurfaceRoughness;
  Map<String, dynamic>? leastToolWear;

  void _importExcel() async {
    try {
      final inputData = await ExcelService().pickAndReadExcel();

      setState(() {
        fileName = ExcelService().fileName;
        processedData = inputData;
        leastSurfaceRoughness = CalculationService.findLeastValue(
          inputData,
          "Surface Roughness (µm)",
        );
        leastToolWear = CalculationService.findLeastValue(
          inputData,
          "Tool Wear (mm)",
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Excel imported successfully")),
      );
    } catch (e) {
      _showError("Error importing Excel: $e");
    }
  }

  void _processExcel() async {
    if (processedData == null) {
      _showError("Please import an Excel file first");
      return;
    }

    final results = CalculationService.calculateResults(processedData!);
    setState(() {
      processedData = results;
      leastSurfaceRoughness = CalculationService.findLeastValue(
        results,
        "Surface Roughness (µm)",
      );
      leastToolWear = CalculationService.findLeastValue(
        results,
        "Tool Wear (mm)",
      );
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/processed_file.xlsx';
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final success = await ExcelService().saveExcel(results, filePath);
      if (success) {
        setState(() {
          savedFilePath = filePath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Excel saved successfully at: $filePath")),
        );
      } else {
        throw Exception("Failed to save the Excel file.");
      }
    } catch (e) {
      _showError("Error processing Excel: $e");
    }
  }

  void _downloadExcel() async {
    if (savedFilePath == null || !File(savedFilePath!).existsSync()) {
      _showError("No processed file available");
      return;
    }

    try {
      await OpenFile.open(savedFilePath!);
    } catch (e) {
      _showError("Error opening file: $e");
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, "/login");
  }

  void _navigateToMyDetails() {
    Navigator.pushNamed(context, "/myDetails");
  }

  void _navigateToHistory() {
    Navigator.pushNamed(
      context,
      "/history",
      arguments: {'email': widget.email},
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "My Details") _navigateToMyDetails();
              if (value == "History") _navigateToHistory();
              if (value == "Logout") _logout();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: "My Details",
                    child: Text("My Details"),
                  ),
                  const PopupMenuItem(value: "History", child: Text("History")),
                  const PopupMenuItem(value: "Logout", child: Text("Logout")),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.email}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _importExcel,
              child: const Text("Import Excel File"),
            ),
            if (fileName != null)
              Text("File: $fileName", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _processExcel,
              child: const Text("Process Excel File"),
            ),
            if (leastSurfaceRoughness != null && leastToolWear != null) ...[
              _buildResultText(
                "Least Surface Roughness",
                leastSurfaceRoughness,
              ),
              _buildResultText("Least Tool Wear", leastToolWear),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _downloadExcel,
              child: const Text("Download Updated Excel"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultText(String label, Map<String, dynamic>? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${data!['leastValue']}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "Inputs (cs, fr, doc): ${data['inputs']}",
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
