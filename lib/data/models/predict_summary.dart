class PredictSummary {
  List<String>? predictSummary;

  PredictSummary({
    this.predictSummary,
  });

  factory PredictSummary.fromJson(Map<String, dynamic> json) => PredictSummary(
        predictSummary: json["predict_summary"] == null
            ? []
            : List<String>.from(
                json["predict_summary"]!.map((x) => x.toString())),
      );
}
