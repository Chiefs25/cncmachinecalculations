import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/excel_service.dart';
import 'package:cncmachinecalculations/services/calculation_service.dart';
import 'package:cncmachinecalculations/services/experimental_service.dart';
import 'package:cncmachinecalculations/services/database_helper.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Theoretical data
  String? fileName;
  String? savedFilePath;
  List<Map<String, dynamic>>? processedData;
  Map<String, dynamic>? leastSurfaceRoughness;
  Map<String, dynamic>? leastToolWear;

  // Experimental data
  String? experimentalFileName;
  List<Map<String, dynamic>>? experimentalData;
  Map<String, dynamic>? minSurfaceRoughness;
  Map<String, dynamic>? minToolWear;

  // Tab Controller
  late TabController _tabController;

  // User name
  String userName = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserName();
  }

  // Load user's name from the database
  void _loadUserName() async {
    if (widget.email == 'guest@user.com') {
      setState(() {
        userName = "Guest";
      });
    } else {
      try {
        final user = await DatabaseHelper.instance.getLoggedInUser(
          widget.email,
        );
        if (user != null && user['name'] != null) {
          setState(() {
            userName = user['name'];
          });
        } else {
          // Fallback to email if name is not available
          setState(() {
            userName = widget.email;
          });
        }
      } catch (e) {
        // If there's an error, use email as fallback
        setState(() {
          userName = widget.email;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Combined Import and Process Function
  void _importAndProcessExcel() async {
    try {
      // First import the Excel file
      final inputData = await ExcelService().pickAndReadExcel();

      setState(() {
        fileName = ExcelService().fileName;
        processedData = inputData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Excel imported successfully, processing..."),
        ),
      );

      // Then process the data
      final results = CalculationService.calculateResults(inputData);
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

      // Save the processed file
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
            SnackBar(content: Text("Excel processed and saved successfully")),
          );
        } else {
          throw Exception("Failed to save the Excel file.");
        }
      } catch (e) {
        _showError("Error saving Excel: $e");
      }
    } catch (e) {
      _showError("Error importing or processing Excel: $e");
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

  // Experimental Functions
  void _importExperimentalExcel() async {
    try {
      final expService = ExperimentalService();
      final data = await expService.pickAndReadExperimentalData();

      setState(() {
        experimentalFileName = expService.fileName;
        experimentalData = data;
        minSurfaceRoughness = ExperimentalService.findMinimumValue(
          data,
          "Surface Roughness (µm)",
        );
        minToolWear = ExperimentalService.findMinimumValue(
          data,
          "Tool Wear (mm)",
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Experimental data imported successfully"),
        ),
      );
    } catch (e) {
      _showError("Error importing experimental data: $e");
    }
  }

  // Navigation Functions
  void _logout() {
    Navigator.pushReplacementNamed(context, "/login");
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
        title: const Text("CNC Machine Calculations"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Theoretical"), Tab(text: "Experimental")],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Logout") _logout();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: "Logout", child: Text("Logout")),
                ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Theoretical Tab
          _buildTheoreticalTab(),

          // Experimental Tab
          _buildExperimentalTab(),
        ],
      ),
    );
  }

  Widget _buildTheoreticalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $userName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Theoretical Calculations",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _importAndProcessExcel,
              child: const Text("Import and Process Excel"),
            ),
            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "File: $fileName",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (leastSurfaceRoughness != null && leastToolWear != null) ...[
              const SizedBox(height: 20),
              const Text(
                "Optimal Parameters (Theoretical):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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

  Widget _buildExperimentalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $userName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Experimental Data Analysis",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _importExperimentalExcel,
              child: const Text("Import Experimental Data"),
            ),
            if (experimentalFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "File: $experimentalFileName",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (minSurfaceRoughness != null && minToolWear != null) ...[
              const SizedBox(height: 20),
              const Text(
                "Optimal Parameters (Experimental):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildExperimentalResultText(
                "Minimum Surface Roughness",
                minSurfaceRoughness,
              ),
              _buildExperimentalResultText("Minimum Tool Wear", minToolWear),
            ],
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

  Widget _buildExperimentalResultText(
    String label,
    Map<String, dynamic>? data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${data!['minimumValue']}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "Experimental Run: ${data['experimentalRun']}",
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "Cutting Speed: ${data['inputs']['Cutting Speed (cs) (rpm)']} rpm",
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "Feed Rate: ${data['inputs']['Feed Rate (fr) (mm/min)']} mm/min",
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "Depth of Cut: ${data['inputs']['Depth of Cut (doc) (mm)']} mm",
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
