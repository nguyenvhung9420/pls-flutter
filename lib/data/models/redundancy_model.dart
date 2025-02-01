import 'package:flutter/material.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/presentation/models/composite.dart';

class RedundancyModel {
  String name;
  Composite compositeForGlobal;
  Composite compositeForFormative;

  RedundancyModel({
    required this.name,
    required this.compositeForGlobal,
    required this.compositeForFormative,
  });

  String makeModelString() {
    String formativeCompositeString = compositeForFormative.makeCompositeCommandString();
    String globalCompositeString = compositeForGlobal.makeCompositeCommandString();

    String? formativeCompositeName = compositeForFormative.name;
    String? globalCompositeName = compositeForGlobal.name;

    String finalString = """# Create measurement model
          ${name}_redundancy_mm <- constructs(
            $formativeCompositeString,
            $globalCompositeString
          )

          # Create structural model
          ${name}_redundancy_sm <- relationships(
            paths(from = c("$formativeCompositeName"), to = c("$globalCompositeName"))
          )

          # Estimate the model
          ${name}_redundancy_pls_model <- estimate_pls(
            data = corp_rep_data,
            measurement_model = ${name}_redundancy_mm,
            structural_model = ${name}_redundancy_sm,
            missing = mean_replacement,
            missing_value = "-99")

          # Summarize the model
          sum_red_model <- summary(${name}_redundancy_pls_model)
          """;
    debugPrint(">>> finalString: $finalString");
    return finalString;
  }
}
