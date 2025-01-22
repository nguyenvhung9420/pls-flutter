class BootstrapSummary {
  List<String>? nboots;
  List<String>? bootstrappedPaths;
  List<String>? bootstrappedWeights;
  List<String>? bootstrappedLoadings;
  List<String>? bootstrappedHtmt;
  List<String>? bootstrappedTotalPaths;

  BootstrapSummary({
    this.nboots,
    this.bootstrappedPaths,
    this.bootstrappedWeights,
    this.bootstrappedLoadings,
    this.bootstrappedHtmt,
    this.bootstrappedTotalPaths,
  });

  List<Map<String, String>> getBootstrapSummaryList() {
    return [
      {"name": "Nboots", "value": nboots?.join("\n") ?? ""},
      {"name": "Bootstrapped Paths", "value": bootstrappedPaths?.join("\n") ?? ""},
      {"name": "Bootstrapped Weights", "value": bootstrappedWeights?.join("\n") ?? ""},
      {"name": "Bootstrapped Loadings", "value": bootstrappedLoadings?.join("\n") ?? ""},
      {"name": "Bootstrapped HTMT", "value": bootstrappedHtmt?.join("\n") ?? ""},
      {"name": "Bootstrapped Total Paths", "value": bootstrappedTotalPaths?.join("\n") ?? ""},
    ];
  }

  factory BootstrapSummary.fromJson(Map<String, dynamic> json) => BootstrapSummary(
        nboots: json["nboots"] == null ? [] : List<String>.from(json["nboots"]!.map((x) => x)),
        bootstrappedPaths:
            json["bootstrapped_paths"] == null ? [] : List<String>.from(json["bootstrapped_paths"]!.map((x) => x)),
        bootstrappedWeights:
            json["bootstrapped_weights"] == null ? [] : List<String>.from(json["bootstrapped_weights"]!.map((x) => x)),
        bootstrappedLoadings: json["bootstrapped_loadings"] == null
            ? []
            : List<String>.from(json["bootstrapped_loadings"]!.map((x) => x)),
        bootstrappedHtmt:
            json["bootstrapped_HTMT"] == null ? [] : List<String>.from(json["bootstrapped_HTMT"]!.map((x) => x)),
        bootstrappedTotalPaths: json["bootstrapped_total_paths"] == null
            ? []
            : List<String>.from(json["bootstrapped_total_paths"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "nboots": nboots == null ? [] : List<dynamic>.from(nboots!.map((x) => x)),
        "bootstrapped_paths": bootstrappedPaths == null ? [] : List<dynamic>.from(bootstrappedPaths!.map((x) => x)),
        "bootstrapped_weights":
            bootstrappedWeights == null ? [] : List<dynamic>.from(bootstrappedWeights!.map((x) => x)),
        "bootstrapped_loadings":
            bootstrappedLoadings == null ? [] : List<dynamic>.from(bootstrappedLoadings!.map((x) => x)),
        "bootstrapped_HTMT": bootstrappedHtmt == null ? [] : List<dynamic>.from(bootstrappedHtmt!.map((x) => x)),
        "bootstrapped_total_paths":
            bootstrappedTotalPaths == null ? [] : List<dynamic>.from(bootstrappedTotalPaths!.map((x) => x)),
      };
}
