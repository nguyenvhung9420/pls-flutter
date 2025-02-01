import 'package:pls_flutter/presentation/mediation_analysis/mediation_analysis_screen.dart';

class SpecificEffectSignificance {
  MediationInput? forInput;
  List<String>? specificEffectSignificance;

  SpecificEffectSignificance({
    this.specificEffectSignificance,
  });

  String getForInput() {
    if (forInput == null) {
      return "";
    }
    return 'From ${forInput!.from} to ${forInput!.to} through ${forInput!.through}';
  }

  factory SpecificEffectSignificance.fromJson(Map<String, dynamic> json) => SpecificEffectSignificance(
        specificEffectSignificance: json["specific_effect_significance"] == null
            ? []
            : List<String>.from(json["specific_effect_significance"]!.map((x) => x.toString())),
      );
}
