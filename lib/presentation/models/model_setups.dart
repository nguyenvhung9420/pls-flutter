class ConfiguredModel {
  List<Composite> composites;
  List<RelationshipPath> paths;
  String delimiter;
  String filePath;
  bool usePathWeighting;
  ConfiguredModel(
      {required this.composites,
      required this.paths,
      required this.delimiter,
      required this.filePath,
      required this.usePathWeighting});
}

class MultiItem {
  String prefix;
  int from;
  int to;
  MultiItem({required this.prefix, required this.from, required this.to});
}

class RelationshipPath {
  List<String> from;
  List<String> to;
  RelationshipPath({required this.from, required this.to});

  String makePathString() {
    String fromString = from.map((String e) => '"$e"').join(", ");
    String toString = to.map((String e) => '"$e"').join(", ");
    String finalString = 'paths(from = c($fromString), to = c($toString))';
    return finalString;
  }
}

class Composite {
  // # pls_model:
  // # - constructs -> composites:
  // #     - name
  // #     - multi_items( prefix, from, to )
  // #     - single_item( name )
  // # - relationships:
  // #     - [ paths( from [ ] , to [ ] ) ]
  // # - inner_weights
  // # - missing
  // # - missing_value

//   # Create the measurement model
// corp_rep_mm_mod <- constructs(
//   composite("QUAL", multi_items("qual_", 1:8), weights = mode_B),
//   composite("PERF", multi_items("perf_", 1:5), weights = mode_B),
//   composite("CSOR", multi_items("csor_", 1:5), weights = mode_B),
//   composite("ATTR", multi_items("attr_", 1:3), weights = mode_B),
//   composite("COMP", multi_items("comp_", 1:3)),
//   composite("LIKE", multi_items("like_", 1:3)),
//   composite("CUSA", single_item("cusa")),
//   composite("SC", multi_items("switch_", 1:4)),
//   composite("CUSL", multi_items("cusl_", 1:3)),
//   interaction_term(iv = "CUSA", moderator = "SC", method = two_stage))

// # Create the structural model
// corp_rep_sm_mod <- relationships(
//   paths(from = c("QUAL", "PERF", "CSOR", "ATTR"), to = c("COMP", "LIKE")),
//   paths(from = c("COMP", "LIKE"), to = c("CUSA", "CUSL")),
//   paths(from = c("CUSA", "SC", "CUSA*SC"), to = c("CUSL"))
// )

  String? name;
  String? weight;

  String? singleItem;
  MultiItem? multiItem;
  bool isMulti;

  bool isInteractionTerm;
  String? iv;
  String? moderator;

  Composite({
    required this.name,
    required this.weight,
    required this.singleItem,
    required this.multiItem,
    required this.isMulti,
    required this.isInteractionTerm,
    required this.iv,
    required this.moderator,
  });

  String makeCompositeCommandString() {
    String? compositeName = name;
    String? itemPrefix = multiItem?.prefix;
    String? singleItemName = singleItem;
    String range = "${multiItem?.from}:${multiItem?.to}";
    String itemString = "";
    String finalString = "";
    String weightModeB = weight == "mode_B" ? ", weights = mode_B" : "";

    if (isInteractionTerm) {
      itemString =
          'interaction_term(iv = "${iv}", moderator = "${moderator}", method = two_stage)';
      finalString = itemString;
    } else if (isMulti) {
      itemString = 'multi_items("$itemPrefix", $range)';
      finalString = 'composite("$compositeName", $itemString $weightModeB)';
    } else {
      itemString = 'single_item("$singleItemName")';
      finalString = 'composite("$compositeName", $itemString $weightModeB)';
    }
    return finalString;
  }
}
