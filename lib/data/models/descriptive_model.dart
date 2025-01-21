import 'package:pls_flutter/data/models/correlation_model.dart';

class Descriptives {
  Correlations? statistics;
  Correlations? correlations;

  Descriptives({
    this.statistics,
    this.correlations,
  });

  factory Descriptives.fromJson(Map<String, dynamic> json) => Descriptives(
        statistics: json["statistics"] == null
            ? null
            : Correlations.fromJson(json["statistics"]),
        correlations: json["correlations"] == null
            ? null
            : Correlations.fromJson(json["correlations"]),
      );

  Map<String, dynamic> toJson() => {
        "statistics": statistics?.toJson(),
        "correlations": correlations?.toJson(),
      };
}
