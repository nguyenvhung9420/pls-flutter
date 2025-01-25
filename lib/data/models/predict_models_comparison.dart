class PredictModelsComparison {
  List<String>? itcriteriaVector;

  PredictModelsComparison({
    this.itcriteriaVector,
  });

  factory PredictModelsComparison.fromJson(Map<String, dynamic> json) =>
      PredictModelsComparison(
        itcriteriaVector: json["itcriteria_vector"] == null
            ? []
            : List<String>.from(
                json["itcriteria_vector"]!.map((x) => x.toString())),
      );
}
