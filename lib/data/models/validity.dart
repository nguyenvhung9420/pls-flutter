class Validity {
  List<String>? vifItems;
  List<String>? htmt;
  List<String>? flCriteria;
  List<String>? crossLoadings;

  Validity({
    this.vifItems,
    this.htmt,
    this.flCriteria,
    this.crossLoadings,
  });

  List<Map<String, String>> getValidityList() {
    return [
      {"name": "VIF Items", "value": vifItems?.join("\n") ?? ""},
      {"name": "HTMT", "value": htmt?.join("\n") ?? ""},
      {"name": "FL Criteria", "value": flCriteria?.join("\n") ?? ""},
      {"name": "Cross Loadings", "value": crossLoadings?.join("\n") ?? ""},
    ];
  }

  factory Validity.fromJson(Map<String, dynamic> json) => Validity(
        vifItems: json["vif_items"] == null ? [] : List<String>.from(json["vif_items"]!.map((x) => x)),
        htmt: json["htmt"] == null ? [] : List<String>.from(json["htmt"]!.map((x) => x)),
        flCriteria: json["fl_criteria"] == null ? [] : List<String>.from(json["fl_criteria"]!.map((x) => x)),
        crossLoadings: json["cross_loadings"] == null ? [] : List<String>.from(json["cross_loadings"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "vif_items": vifItems == null ? [] : List<dynamic>.from(vifItems!.map((x) => x)),
        "htmt": htmt == null ? [] : List<dynamic>.from(htmt!.map((x) => x)),
        "fl_criteria": flCriteria == null ? [] : List<dynamic>.from(flCriteria!.map((x) => x)),
        "cross_loadings": crossLoadings == null ? [] : List<dynamic>.from(crossLoadings!.map((x) => x)),
      };
}
