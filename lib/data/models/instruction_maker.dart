import 'package:pls_flutter/presentation/models/model_setups.dart';

class InstructionMaker {
  static String makeInstructions({required ConfiguredModel model}) {
    List<String> constructs = model.composites.map((Composite composite) {
      return composite.makeCompositeCommandString();
    }).toList();

    List<String> paths = model.paths.map((RelationshipPath path) {
      return path.makePathString();
    }).toList();

    String constructString = constructs.join(", ");
    String pathsString = paths.join(", ");
    String usingPathWeighting = model.usePathWeighting ? "inner_weights = path_weighting," : "";

    return """corp_rep_mm <- constructs(
            $constructString
          )

          corp_rep_sm <- relationships(
            $pathsString
          )

          corp_rep_pls_model <- estimate_pls(
            data = corp_rep_data,
            measurement_model = corp_rep_mm,
            structural_model = corp_rep_sm,
            $usingPathWeighting
            missing = mean_replacement,
            missing_value = "-99"
          )""";
  }
}
