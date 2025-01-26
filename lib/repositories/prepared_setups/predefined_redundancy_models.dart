// # Create measurement model
// ATTR_redundancy_mm <- constructs(
//   composite("ATTR_F", multi_items("attr_", 1:3), weights = mode_B),
//   composite("ATTR_G", single_item("attr_global"))
// )

// # Create structural model
// ATTR_redundancy_sm <- relationships(
//   paths(from = c("ATTR_F"), to = c("ATTR_G"))
// )
// # Create measurement model
// CSOR_redundancy_mm <- constructs(
//   composite("CSOR_F", multi_items("csor_", 1:5), weights = mode_B),
//   composite("CSOR_G", single_item("csor_global"))
// )

// # Create structural model
// CSOR_redundancy_sm <- relationships(
//   paths(from = c("CSOR_F"), to = c("CSOR_G"))
// )

// # Create measurement model
// PERF_redundancy_mm <- constructs(
//   composite("PERF_F", multi_items("perf_", 1:5), weights = mode_B),
//   composite("PERF_G", single_item("perf_global"))
// )

// # Create structural model
// PERF_redundancy_sm <- relationships(
//   paths(from = c("PERF_F"), to = c("PERF_G"))
// )

// # Create measurement model
// QUAL_redundancy_mm <- constructs(
//   composite("QUAL_F", multi_items("qual_", 1:8), weights = mode_B),
//   composite("QUAL_G", single_item("qual_global"))
// )

// # Create structural model
// QUAL_redundancy_sm <- relationships(
//   paths(from = c("QUAL_F"), to = c("QUAL_G"))
// )

import 'package:pls_flutter/data/models/redundancy_model.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';

final List<RedundancyModel> predefinedRedundancyModels = [
  RedundancyModel(
    name: 'ATTR',
    compositeForFormative: Composite(
      name: "ATTR_F",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "attr_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    compositeForGlobal: Composite(
      name: "ATTR_G",
      weight: null,
      singleItem: "attr_global",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
  ),
  RedundancyModel(
    name: 'CSOR',
    compositeForFormative: Composite(
      name: "CSOR_F",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "csor_", from: 1, to: 5),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    compositeForGlobal: Composite(
      name: "CSOR_G",
      weight: null,
      singleItem: "csor_global",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
  ),
  RedundancyModel(
    name: 'PERF',
    compositeForFormative: Composite(
      name: "PERF_F",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "perf_", from: 1, to: 5),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    compositeForGlobal: Composite(
      name: "PERF_G",
      weight: null,
      singleItem: "perf_global",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
  ),
  RedundancyModel(
    name: 'QUAL',
    compositeForFormative: Composite(
      name: "QUAL_F",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "qual_", from: 1, to: 8),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    compositeForGlobal: Composite(
      name: "QUAL_G",
      weight: null,
      singleItem: "qual_global",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
  ),
];
