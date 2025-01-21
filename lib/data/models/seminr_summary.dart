import 'package:pls_flutter/data/models/descriptive_model.dart';
import 'package:pls_flutter/data/models/validity.dart';

class SeminrSummary {
  List<String>? meta;
  List<String>? iterations;
  List<String>? paths;
  List<String>? totalEffects;
  List<String>? totalIndirectEffects;
  List<String>? loadings;
  List<String>? weights;
  List<String>? reliability;
  List<String>? itCriteria;
  List<String>? vifAntecedents;
  List<String>? fSquare;

  Validity? validity;
  Descriptives? descriptives;

  SeminrSummary({
    this.meta,
    this.iterations,
    this.paths,
    this.totalEffects,
    this.totalIndirectEffects,
    this.loadings,
    this.weights,
    this.reliability,
    this.validity,
    this.vifAntecedents,
    this.fSquare,
    this.descriptives,
    this.itCriteria,
  });

  factory SeminrSummary.fromJson(Map<String, dynamic> json) => SeminrSummary(
        meta: json["meta"] == null
            ? []
            : List<String>.from(json["meta"]!.map((x) => x)),
        iterations: json["iterations"] == null
            ? []
            : List<String>.from(json["iterations"]!.map((x) => x)),
        paths: json["paths"] == null
            ? []
            : List<String>.from(json["paths"]!.map((x) => x)),
        totalEffects: json["total_effects"] == null
            ? []
            : List<String>.from(json["total_effects"]!.map((x) => x)),
        totalIndirectEffects: json["total_indirect_effects"] == null
            ? []
            : List<String>.from(json["total_indirect_effects"]!.map((x) => x)),
        loadings: json["loadings"] == null
            ? []
            : List<String>.from(json["loadings"]!.map((x) => x)),
        weights: json["weights"] == null
            ? []
            : List<String>.from(json["weights"]!.map((x) => x)),
        reliability: json["reliability"] == null
            ? []
            : List<String>.from(json["reliability"]!.map((x) => x)),
        validity: json["validity"] == null
            ? null
            : Validity.fromJson(json["validity"]),
        vifAntecedents: json["vif_antecedents"] == null
            ? []
            : List<String>.from(json["vif_antecedents"]!.map((x) => x)),
        fSquare: json["fSquare"] == null
            ? []
            : List<String>.from(json["fSquare"]!.map((x) => x)),
        descriptives: json["descriptives"] == null
            ? null
            : Descriptives.fromJson(json["descriptives"]),
        itCriteria: json["it_criteria"] == null
            ? []
            : List<String>.from(json["it_criteria"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "meta": meta == null ? [] : List<dynamic>.from(meta!.map((x) => x)),
        "iterations": iterations == null
            ? []
            : List<dynamic>.from(iterations!.map((x) => x)),
        "paths": paths == null ? [] : List<dynamic>.from(paths!.map((x) => x)),
        "total_effects": totalEffects == null
            ? []
            : List<dynamic>.from(totalEffects!.map((x) => x)),
        "total_indirect_effects": totalIndirectEffects == null
            ? []
            : List<dynamic>.from(totalIndirectEffects!.map((x) => x)),
        "loadings":
            loadings == null ? [] : List<dynamic>.from(loadings!.map((x) => x)),
        "weights":
            weights == null ? [] : List<dynamic>.from(weights!.map((x) => x)),
        "reliability": reliability == null
            ? []
            : List<dynamic>.from(reliability!.map((x) => x)),
        "validity": validity?.toJson(),
        "vif_antecedents": vifAntecedents == null
            ? []
            : List<dynamic>.from(vifAntecedents!.map((x) => x)),
        "fSquare":
            fSquare == null ? [] : List<dynamic>.from(fSquare!.map((x) => x)),
        "descriptives": descriptives?.toJson(),
        "it_criteria": itCriteria == null
            ? []
            : List<dynamic>.from(itCriteria!.map((x) => x)),
      };
}
