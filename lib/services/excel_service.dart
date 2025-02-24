import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExcelService {
  File? _selectedFile;
  String? _fileName;
  File? _updatedFile;

  String? get fileName => _fileName;

  Future<List<Map<String, double>>> pickAndReadExcel() async {
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

      return await _readExcelAndConvert(_selectedFile!);
    } catch (e) {
      throw Exception('Error picking Excel file: $e');
    }
  }

  Future<List<Map<String, double>>> _readExcelAndConvert(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }

    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final dataList = <Map<String, double>>[];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.length < 4) continue;

          final cuttingSpeed =
              double.tryParse(row[1]?.value.toString() ?? '') ?? 0.0;
          final feedRate =
              double.tryParse(row[2]?.value.toString() ?? '') ?? 0.0;
          final depthOfCut =
              double.tryParse(row[3]?.value.toString() ?? '') ?? 0.0;

          if (cuttingSpeed > 0 && feedRate > 0 && depthOfCut > 0) {
            dataList.add({
              "Cutting Speed (cs) (rpm)": cuttingSpeed,
              "Feed Rate (fr) (mm/min)": feedRate,
              "Depth of Cut (doc) (mm)": depthOfCut,
            });
          }
        }
      }
      return dataList;
    } catch (e) {
      throw Exception('Error reading Excel file: $e');
    }
  }

  Future<void> processAndOpenExcel(
    List<Map<String, double>> processedData,
  ) async {
    if (_selectedFile == null) throw Exception('No file selected');

    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet()]!;

      sheet.appendRow(
        [
          'Cutting Speed (cs) (rpm)',
          'Feed Rate (fr) (mm/min)',
          'Depth of Cut (doc) (mm)',
          'Surface Roughness (µm)',
          'Tool Wear (mm)',
        ].map((v) => TextCellValue(v)).toList(),
      );

      for (var row in processedData) {
        sheet.appendRow([
          DoubleCellValue(row['Cutting Speed (cs) (rpm)']!),
          DoubleCellValue(row['Feed Rate (fr) (mm/min)']!),
          DoubleCellValue(row['Depth of Cut (doc) (mm)']!),
          DoubleCellValue(row['Surface Roughness (µm)']!),
          DoubleCellValue(row['Tool Wear (mm)']!),
        ]);
      }

      _updatedFile = await _saveExcelFile(excel);
      await OpenFile.open(_updatedFile!.path); // Opens updated file immediately
    } catch (e) {
      throw Exception('Error processing Excel file: $e');
    }
  }

  Future<File> _saveExcelFile(Excel excel) async {
    final outputBytes = excel.encode();
    if (outputBytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    final directory =
        await getDownloadsDirectory() ?? await getTemporaryDirectory();
    final outputPath = '${directory.path}/updated_results.xlsx';

    final file = File(outputPath);
    await file.writeAsBytes(outputBytes);

    return file;
  }

  Future<void> openUpdatedExcelFile() async {
    if (_updatedFile == null) {
      throw Exception('No updated file available');
    }

    if (await _updatedFile!.exists()) {
      await OpenFile.open(_updatedFile!.path);
    } else {
      throw Exception('Updated Excel file not found');
    }
  }
}
