class Correlations {
  List<String>? items;
  List<String>? constructs;

  Correlations({
    this.items,
    this.constructs,
  });

  factory Correlations.fromJson(Map<String, dynamic> json) => Correlations(
        items: json["items"] == null
            ? []
            : List<String>.from(json["items"]!.map((x) => x)),
        constructs: json["constructs"] == null
            ? []
            : List<String>.from(json["constructs"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
        "constructs": constructs == null
            ? []
            : List<dynamic>.from(constructs!.map((x) => x)),
      };
}
