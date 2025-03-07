import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExperimentalService {
  File? _selectedFile;
  String? _fileName;

  String? get fileName => _fileName;

  Future<List<Map<String, dynamic>>> pickAndReadExperimentalData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final path = result.files.single.path;
      if (path == null) throw Exception('Invalid file path');

      _selectedFile = File(path);
      _fileName = result.files.single.name;

      return await _readExperimentalExcelData(_selectedFile!);
    } catch (e) {
      throw Exception('Error picking experimental Excel file: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _readExperimentalExcelData(
    File file,
  ) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }

    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final dataList = <Map<String, dynamic>>[];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        // Get header row to identify column indices
        final headers = sheet.rows[0];
        if (headers.length < 5) {
          throw Exception(
            'Experimental data requires at least 5 columns (cs, fr, doc, sr, tw)',
          );
        }

        // Find column indices
        int? runIndex, csIndex, frIndex, docIndex, srIndex, twIndex;

        for (int i = 0; i < headers.length; i++) {
          var header = headers[i]?.value.toString().trim().toLowerCase();
          if (header == null) continue;

          if (header.contains('experimental run'))
            runIndex = i;
          else if (header.contains('cutting speed'))
            csIndex = i;
          else if (header.contains('feed rate'))
            frIndex = i;
          else if (header.contains('depth of cut'))
            docIndex = i;
          else if (header.contains('surface roughness'))
            srIndex = i;
          else if (header.contains('tool wear'))
            twIndex = i;
        }

        // Verify all required columns are found - Experimental Run is now optional
        if (csIndex == null ||
            frIndex == null ||
            docIndex == null ||
            srIndex == null ||
            twIndex == null) {
          throw Exception('Required columns not found in experimental data');
        }

        // Read data rows
        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          // Get the maximum index we need to check
          final maxIndex = max([
            csIndex,
            frIndex,
            docIndex,
            srIndex,
            twIndex,
            if (runIndex != null) runIndex,
          ]);

          if (row.length <= maxIndex) continue;

          // Experimental Run is now optional
          final run =
              runIndex != null
                  ? (row[runIndex]?.value?.toString() ?? '')
                  : 'Run ${i}';
          final cuttingSpeed =
              double.tryParse(row[csIndex]?.value.toString() ?? '') ?? 0.0;
          final feedRate =
              double.tryParse(row[frIndex]?.value.toString() ?? '') ?? 0.0;
          final depthOfCut =
              double.tryParse(row[docIndex]?.value.toString() ?? '') ?? 0.0;
          final surfaceRoughness =
              double.tryParse(row[srIndex]?.value.toString() ?? '') ?? 0.0;
          final toolWear =
              double.tryParse(row[twIndex]?.value.toString() ?? '') ?? 0.0;

          if (cuttingSpeed > 0 && feedRate > 0 && depthOfCut > 0) {
            dataList.add({
              "Experimental Run": run,
              "Cutting Speed (cs) (rpm)": cuttingSpeed,
              "Feed Rate (fr) (mm/min)": feedRate,
              "Depth of Cut (doc) (mm)": depthOfCut,
              "Surface Roughness (µm)": surfaceRoughness,
              "Tool Wear (mm)": toolWear,
            });
          }
        }
      }
      return dataList;
    } catch (e) {
      throw Exception('Error reading experimental Excel file: $e');
    }
  }

  // Find minimum values and their corresponding inputs
  static Map<String, dynamic>? findMinimumValue(
    List<Map<String, dynamic>> data,
    String key,
  ) {
    if (data.isEmpty || !data.first.containsKey(key)) return null;

    var minRow = data.reduce(
      (curr, next) =>
          (curr[key] != null &&
                  next[key] != null &&
                  curr[key] is num &&
                  next[key] is num &&
                  (curr[key] as num) < (next[key] as num))
              ? curr
              : next,
    );

    return {
      'minimumValue': minRow[key],
      'experimentalRun': minRow["Experimental Run"],
      'inputs': {
        "Cutting Speed (cs) (rpm)": minRow["Cutting Speed (cs) (rpm)"],
        "Feed Rate (fr) (mm/min)": minRow["Feed Rate (fr) (mm/min)"],
        "Depth of Cut (doc) (mm)": minRow["Depth of Cut (doc) (mm)"],
      },
    };
  }

  // Helper function to find maximum value in a list
  static T max<T extends num>(List<T> list) {
    if (list.isEmpty) throw Exception('Cannot find max of empty list');
    return list.reduce((curr, next) => curr > next ? curr : next);
  }
}
