import 'package:pls_flutter/presentation/models/model_setups.dart';

// corp_rep_mm <- constructs(
//     composite("COMP", multi_items("comp_", 1:3)),
//     composite("LIKE", multi_items("like_", 1:3)),
//     composite("CUSA", single_item("cusa")),
//     composite("CUSL", multi_items("cusl_", 1:3))
//   )

//   corp_rep_sm <- relationships(
//     paths(from = c("COMP", "LIKE"), to = c("CUSA", "CUSL")),
//     paths(from = c("CUSA"), to = c("CUSL"))
//   )

final ConfiguredModel corpDataModel = ConfiguredModel(
  usePathWeighting: false,
  delimiter: ";",
  filePath: "",
  composites: [
    Composite(
      name: "COMP",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "comp_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "LIKE",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "like_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSA",
      weight: null,
      singleItem: "cusa",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSL",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "cusl_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
  ],
  paths: [
    RelationshipPath(from: ["COMP", "LIKE"], to: ["CUSA", "CUSL"]),
    RelationshipPath(from: ["CUSA"], to: ["CUSL"]),
  ],
);

// corp_rep_mm_ext <- constructs(
//   composite("QUAL", multi_items("qual_", 1:8), weights = mode_B),
//   composite("PERF", multi_items("perf_", 1:5), weights = mode_B),
//   composite("CSOR", multi_items("csor_", 1:5), weights = mode_B),
//   composite("ATTR", multi_items("attr_", 1:3), weights = mode_B),
//   composite("COMP", multi_items("comp_", 1:3)),
//   composite("LIKE", multi_items("like_", 1:3)),
//   composite("CUSA", single_item("cusa")),
//   composite("CUSL", multi_items("cusl_", 1:3)))

// corp_rep_sm_ext <- relationships(
//   paths(from = c("QUAL", "PERF", "CSOR", "ATTR"), to = c("COMP", "LIKE")),
//   paths(from = c("COMP", "LIKE"), to = c("CUSA", "CUSL")),
//   paths(from = c("CUSA"), to = c("CUSL"))
// )

final ConfiguredModel corpDataModelExt = ConfiguredModel(
  usePathWeighting: true,
  delimiter: ";",
  filePath: "",
  composites: [
    Composite(
      name: "QUAL",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "qual_", from: 1, to: 8),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "PERF",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "perf_", from: 1, to: 5),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CSOR",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "csor_", from: 1, to: 5),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "ATTR",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "attr_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "COMP",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "comp_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "LIKE",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "like_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSA",
      weight: null,
      singleItem: "cusa",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSL",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "cusl_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
  ],
  paths: [
    RelationshipPath(
        from: ["QUAL", "PERF", "CSOR", "ATTR"], to: ["COMP", "LIKE"]),
    RelationshipPath(from: ["COMP", "LIKE"], to: ["CUSA", "CUSL"]),
    RelationshipPath(from: ["CUSA"], to: ["CUSL"]),
  ],
);

// # Create the measurement model
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

final ConfiguredModel corpDataModelExtModeration = ConfiguredModel(
  usePathWeighting: true,
  delimiter: ";",
  filePath: "",
  composites: [
    Composite(
      name: "QUAL",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "qual_", from: 1, to: 8),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "PERF",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "perf_", from: 1, to: 5),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CSOR",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "csor_", from: 1, to: 5),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "ATTR",
      weight: "mode_B",
      singleItem: null,
      multiItem: MultiItem(prefix: "attr_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "COMP",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "comp_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "LIKE",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "like_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSA",
      weight: null,
      singleItem: "cusa",
      multiItem: null,
      isMulti: false,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "SC",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "switch_", from: 1, to: 4),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSL",
      weight: null,
      singleItem: null,
      multiItem: MultiItem(prefix: "cusl_", from: 1, to: 3),
      isMulti: true,
      isInteractionTerm: false,
      iv: null,
      moderator: null,
    ),
    Composite(
      name: "CUSA*SC",
      weight: null,
      singleItem: null,
      multiItem: null,
      isMulti: false,
      isInteractionTerm: true,
      iv: "CUSA",
      moderator: "SC",
    ),
  ],
  paths: [
    RelationshipPath(
        from: ["QUAL", "PERF", "CSOR", "ATTR"], to: ["COMP", "LIKE"]),
    RelationshipPath(from: ["COMP", "LIKE"], to: ["CUSA", "CUSL"]),
    RelationshipPath(from: ["CUSA", "SC", "CUSA*SC"], to: ["CUSL"]),
  ],
);
