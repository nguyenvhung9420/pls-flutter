class SpecificEffectSignificance {
  List<String>? specificEffectSignificance;

  SpecificEffectSignificance({
    this.specificEffectSignificance,
  });

  factory SpecificEffectSignificance.fromJson(Map<String, dynamic> json) =>
      SpecificEffectSignificance(
        specificEffectSignificance: json["specific_effect_significance"] == null
            ? []
            : List<String>.from(
                json["specific_effect_significance"]!.map((x) => x.toString())),
      );
}
