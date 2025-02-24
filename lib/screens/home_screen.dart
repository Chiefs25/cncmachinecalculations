import 'package:flutter/material.dart';
import '../services/excel_service.dart';
import '../services/calculation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExcelService _excelService = ExcelService();
  List<Map<String, double>> _processedResults = [];
  Map<String, dynamic>? _leastSRData;
  Map<String, dynamic>? _leastTWData;

  Future<void> _pickFile() async {
    try {
      List<Map<String, double>> data = await _excelService.pickAndReadExcel();
      List<Map<String, double>> results = CalculationService.calculateResults(
        data,
      );

      setState(() {
        _processedResults = results;
        _leastSRData = CalculationService.findLeastValue(
          results,
          'Surface Roughness (µm)',
        );
        _leastTWData = CalculationService.findLeastValue(
          results,
          'Tool Wear (mm)',
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing file: $e')));
      }
    }
  }

  Future<void> _downloadFile() async {
    if (_processedResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to save. Process first.')),
      );
      return;
    }

    try {
      await _excelService.processAndOpenExcel(_processedResults);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CNC Machine Calculations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Import & Process Excel Sheet'),
            ),
            if (_excelService.fileName != null)
              Text(
                'File: ${_excelService.fileName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (_leastSRData != null)
              Text(
                'Least Surface Roughness: ${_leastSRData!['leastValue']} at Cutting Speed: ${_leastSRData!['inputs']['Cutting Speed (cs) (rpm)']}, Feed Rate: ${_leastSRData!['inputs']['Feed Rate (fr) (mm/min)']}, Depth of Cut: ${_leastSRData!['inputs']['Depth of Cut (doc) (mm)']}',
              ),
            if (_leastTWData != null)
              Text(
                'Least Tool Wear: ${_leastTWData!['leastValue']} at Cutting Speed: ${_leastTWData!['inputs']['Cutting Speed (cs) (rpm)']}, Feed Rate: ${_leastTWData!['inputs']['Feed Rate (fr) (mm/min)']}, Depth of Cut: ${_leastTWData!['inputs']['Depth of Cut (doc) (mm)']}',
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _downloadFile,
              child: const Text('Download Updated Excel'),
            ),
          ],
        ),
      ),
    );
  }
}
