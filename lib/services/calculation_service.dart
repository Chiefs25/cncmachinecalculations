import 'dart:math';

class CalculationService {
  // Calculate Surface Roughness and Tool Wear
  static List<Map<String, double>> calculateResults(
    List<Map<String, double>> inputData,
  ) {
    List<Map<String, double>> results = [];

    for (var row in inputData) {
      double cuttingSpeed = row["Cutting Speed (cs) (rpm)"] ?? 0.0;
      double feedRate = row["Feed Rate (fr) (mm/min)"] ?? 0.0;
      double depthOfCut = row["Depth of Cut (doc) (mm)"] ?? 0.0;

      if (cuttingSpeed <= 0 || feedRate <= 0 || depthOfCut <= 0) continue;

      // Updated Correct Formulas (Ensure they match real-world calculations)
      double surfaceRoughness = (0.125 * feedRate * feedRate) / depthOfCut;
      double toolWear =
          (0.0003 * cuttingSpeed * cuttingSpeed * sqrt(feedRate)) /
          pow(depthOfCut, 0.2);

      results.add({
        "Cutting Speed (cs) (rpm)": cuttingSpeed,
        "Feed Rate (fr) (mm/min)": feedRate,
        "Depth of Cut (doc) (mm)": depthOfCut,
        "Surface Roughness (µm)": surfaceRoughness,
        "Tool Wear (mm)": toolWear,
      });
    }

    return results;
  }

  // Find the row with the least value of a given parameter
  static Map<String, dynamic>? findLeastValue(
    List<Map<String, double>> data,
    String key,
  ) {
    if (data.isEmpty || !data.first.containsKey(key)) return null;

    var minRow = data.reduce(
      (curr, next) =>
          (curr[key] ?? double.infinity) < (next[key] ?? double.infinity)
              ? curr
              : next,
    );

    return {
      'leastValue': minRow[key],
      'inputs': {
        "Cutting Speed (cs) (rpm)": minRow["Cutting Speed (cs) (rpm)"],
        "Feed Rate (fr) (mm/min)": minRow["Feed Rate (fr) (mm/min)"],
        "Depth of Cut (doc) (mm)": minRow["Depth of Cut (doc) (mm)"],
      },
    };
  }
}
