import 'package:pls_flutter/presentation/models/composite.dart';
import 'package:pls_flutter/presentation/models/relationship_path.dart';

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
