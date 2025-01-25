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

  String? name;
  String? weight;
  String? singleItem;
  MultiItem? multiItem;
  bool isMulti;
  Composite(
      {required this.name,
      required this.weight,
      required this.singleItem,
      required this.multiItem,
      required this.isMulti});
}
