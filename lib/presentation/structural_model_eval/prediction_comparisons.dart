import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pls_flutter/data/models/predict_models_comparison.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pls_flutter/presentation/base_state/pls_textfield.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
import 'package:pls_flutter/repositories/prepared_setups/prepared_setups.dart';
import 'package:pls_flutter/utils/theme_constant.dart';
import 'package:collection/collection.dart';

class ComparePredictionsScreen extends StatefulWidget {
  final String accessToken;
  final Function(ConfiguredModel) onDoneWithModelSetup;
  final ConfiguredModel? configuredModel;

  const ComparePredictionsScreen(
      {super.key, required this.onDoneWithModelSetup, required this.configuredModel, required this.accessToken});

  @override
  State<ComparePredictionsScreen> createState() => _ComparePredictionsScreenState();
}

class _ComparePredictionsScreenState extends BaseState<ComparePredictionsScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  String? filePath;
  List<Composite> composites = [];
  List<List<RelationshipPath>> paths = [];
  int? compositeIndexInEditing;
  (int, int)? pathIndexInEditing; // ( pathSetIndex, pathInnerIndex )
  bool usePathWeighting = false;
  String compareFrom = "";
  String compareTo = "";
  Map<String, dynamic> comparisonResults = {};

  @override
  void initState() {
    super.initState();
    _populateData();
  }

  void _populateData() async {
    if (widget.configuredModel != null) {
      filePath = widget.configuredModel!.filePath;
      composites = widget.configuredModel!.composites;
      paths = [List.from(widget.configuredModel!.paths)];
    }
  }

  void _populateDataFromModel(ConfiguredModel configuredModel) async {
    if (filePath == null) {
      debugPrint(">>> filePath is null");
      return;
    }

    filePath = filePath;
    composites = configuredModel.composites;
    paths = [List.from(configuredModel.paths)]; // just the first path
    usePathWeighting = configuredModel.usePathWeighting;
    setState(() {});
  }

  List<String> possibleCompositeNames() {
    List<String> normalComposites =
        composites.map((Composite e) => e.name ?? "").where((String element) => element.isNotEmpty).toList();
    return normalComposites;
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _singleItemController = TextEditingController();
  final TextEditingController _compareFromController = TextEditingController();
  final TextEditingController _compareToController = TextEditingController();

  void makeComparison() async {
    if (compareFrom.isEmpty || compareTo.isEmpty) {
      showAlertView(
          title: "Missing Values",
          body: "Please fill in 'Compare From' and 'Compare To' text fields.",
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ]);
      return;
    }

    if (filePath == null) {
      debugPrint(">>> filePath is null");
      return;
    }

    enableLoading();

    // getComparePredictModels:
    PredictModelsComparison? predict = await PLSRepository().getComparePredictModels(
      userToken: widget.accessToken,
      filePath: filePath!,
      instructions: makePredictComparisonCommandString(),
    );
    Map<String, dynamic> toReturn = {
      "name": "Predictive model comparisons",
      "value": predict?.itcriteriaVector?.join("\n") ?? ""
    };
    comparisonResults = toReturn;
    setState(() {});
    disableLoading();
  }

  void openEndDrawer() {
    _key.currentState?.openEndDrawer();
  }

  void closeEndDrawer() {
    _key.currentState?.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          ListView(
            // main content
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).viewPadding.top, 16, 16),
            children: [
              makeBottomSheetTitle("Make Prediction Models"),
              SizedBox(height: 24),
              makeSection([
                makeSectionTitle("Variables to compare"),
                ThemeConstant.sizedBox16,
                PLSTextField(
                    controller: _compareFromController,
                    labelText: "Compare from",
                    hintText: 'e.g. "BIC"',
                    onChanged: (String newVal) {
                      setState(() {
                        compareFrom = newVal;
                      });
                    }),
                ThemeConstant.sizedBox8,
                PLSTextField(
                  controller: _compareToController,
                  labelText: "Compare with",
                  hintText: 'e.g. "CUSA"',
                  onChanged: (String newVal) {
                    setState(() {
                      compareTo = newVal;
                    });
                  },
                ),
              ]),
              ThemeConstant.sizedBox16,
              makeSection([
                Row(children: [
                  makeSectionTitle("Measurement model"),
                  Spacer(),
                  TextButton(
                      onPressed: () {
                        composites.add(Composite(
                          name: "[No Name]",
                          weight: null,
                          singleItem: null,
                          multiItem: MultiItem(prefix: "construction", from: 1, to: 1),
                          isMulti: true,
                          isInteractionTerm: false,
                          iv: null,
                          moderator: null,
                        ));
                        compositeIndexInEditing = composites.length - 1;
                        pathIndexInEditing = null;
                        setState(() {});
                      },
                      child: Text("+ Add Construct")),
                ]),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: composites.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          pathIndexInEditing = null;
                          compositeIndexInEditing = index;
                        });
                        populateTextFieldsFromComposite(index);
                        openEndDrawer();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color:
                                compositeIndexInEditing == index ? Theme.of(context).primaryColor : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Builder(builder: (context) {
                                  String finalString = makeCompositeCommandString(index);
                                  return Text(
                                    finalString,
                                    style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                                  );
                                }),
                              ),
                              Icon(Icons.edit),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: paths.length,
                itemBuilder: (BuildContext context, int index) {
                  return eachPathEditing(index);
                },
              ),
              TextButton.icon(
                onPressed: () {
                  List<RelationshipPath> newPathSet = [];
                  // paths.last.forEach((RelationshipPath element) {
                  //   newPathSet.add(element);
                  // });
                  setState(() {
                    paths.add(newPathSet);
                    pathIndexInEditing = null;
                  });
                },
                icon: Icon(Icons.add),
                label: Text("Add more Structural Model"),
              ),
              isLoading
                  ? loadingNotice()
                  : Center(
                      child: ElevatedButton(
                        onPressed: () {
                          String commandString = makePredictComparisonCommandString();
                          debugPrint(commandString);
                          makeComparison();
                        },
                        child: Text("Start Compare"),
                      ),
                    ),
              ThemeConstant.sizedBox16,
              comparisonResults.isNotEmpty
                  ? makeSection(
                      [
                        makeSectionTitle("Comparison Results"),
                        ThemeConstant.sizedBox8,
                        Text((comparisonResults["name"] ?? "") +
                            " in Information Theoretic model selection criteria (IT Criteria)"),
                        SizedBox(height: 8),
                        Text(
                          comparisonResults["value"] ?? "",
                          style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 80),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).viewPadding.top, 16, 16),
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48 / 2),
              ),
              child: Icon(Icons.close),
            ),
          )
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ListView(
          children: [
            // COMPOSITE EDITING
            compositeIndexInEditing == null
                ? Container()
                : ListView(
                    shrinkWrap: true,
                    primary: false,
                    padding: ThemeConstant.padding8(),
                    children: [
                      Text('Construct ${composites[compositeIndexInEditing!].name ?? "Untitled"}'),
                      ThemeConstant.sizedBox16,
                      PLSTextField(
                        controller: _nameController,
                        labelText: "Construct Name",
                        onChanged: (String newVal) {
                          setState(() => composites[compositeIndexInEditing!].name = newVal.toUpperCase());
                        },
                      ),
                      ThemeConstant.sizedBox8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Use mode B for weight?"),
                          Switch(
                            value: composites[compositeIndexInEditing!].weight == "mode_B",
                            onChanged: (bool value) {
                              setState(() => composites[compositeIndexInEditing!].weight = value ? "mode_B" : null);
                            },
                          ),
                        ],
                      ),
                      ThemeConstant.sizedBox8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // interaction_term(iv = "CUSA", moderator = "SC", method = two_stage))
                          Text("Is this an interaction term (for Moderation analysis)?"),
                          Switch(
                            value: composites[compositeIndexInEditing!].isInteractionTerm,
                            onChanged: (bool value) {
                              setState(() => composites[compositeIndexInEditing!].isInteractionTerm = value);
                            },
                          ),
                        ],
                      ),
                      ThemeConstant.sizedBox8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Is this a multi item?"),
                          Switch(
                            value: composites[compositeIndexInEditing!].isMulti,
                            onChanged: (bool value) {
                              setState(() => composites[compositeIndexInEditing!].isMulti = value);
                            },
                          ),
                        ],
                      ),
                      ThemeConstant.sizedBox8,
                      Builder(builder: (ctx) {
                        if (composites[compositeIndexInEditing!].isInteractionTerm) {
                          return Column(mainAxisSize: MainAxisSize.min, children: [
                            PLSTextField(
                              controller: _prefixController,
                              labelText: "Independent Variable (IV)",
                              hintText: 'e.g. "CUSA"',
                              onChanged: (String newVal) {
                                setState(() {
                                  composites[compositeIndexInEditing!].iv = newVal;
                                  composites[compositeIndexInEditing!].name =
                                      '${composites[compositeIndexInEditing!].iv}*${composites[compositeIndexInEditing!].moderator}';
                                });
                                _nameController.text = composites[compositeIndexInEditing!].name ?? "";
                              },
                            ),
                            ThemeConstant.sizedBox8,
                            PLSTextField(
                              controller: _fromController,
                              labelText: "Moderator",
                              onChanged: (String newVal) {
                                setState(() {
                                  composites[compositeIndexInEditing!].moderator = newVal;
                                  composites[compositeIndexInEditing!].name =
                                      '${composites[compositeIndexInEditing!].iv}*${composites[compositeIndexInEditing!].moderator}';

                                  _nameController.text = composites[compositeIndexInEditing!].name ?? "";
                                });
                              },
                            ),
                          ]);
                        }

                        if (composites[compositeIndexInEditing!].isMulti) {
                          return Column(mainAxisSize: MainAxisSize.min, children: [
                            PLSTextField(
                              controller: _prefixController,
                              labelText: "Prefix",
                              hintText: 'e.g. "cusl_"',
                              onChanged: (String newVal) {
                                setState(() => composites[compositeIndexInEditing!].multiItem?.prefix = newVal);
                              },
                            ),
                            ThemeConstant.sizedBox8,
                            PLSTextField(
                              controller: _fromController,
                              labelText: "From",
                              onChanged: (String newVal) {
                                setState(
                                    () => composites[compositeIndexInEditing!].multiItem?.from = int.parse(newVal));
                              },
                            ),
                            ThemeConstant.sizedBox8,
                            PLSTextField(
                                controller: _toController,
                                labelText: "To",
                                onChanged: (String newVal) {
                                  setState(
                                      () => composites[compositeIndexInEditing!].multiItem?.to = int.parse(newVal));
                                })
                          ]);
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Single Item Variable"),
                            SizedBox(height: 5),
                            PLSTextField(
                              controller: _singleItemController,
                              labelText: "Variable Name",
                              onChanged: (String newVal) {
                                setState(() => composites[compositeIndexInEditing!].singleItem = newVal);
                              },
                            ),
                          ],
                        );
                      }),
                      ThemeConstant.sizedBox16,
                      TextButton.icon(
                        label: Text("Delete"),
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            composites.removeAt(compositeIndexInEditing!);
                          });
                        },
                      ),
                      ThemeConstant.sizedBox8,
                      TextButton.icon(
                        label: Text("Save"),
                        icon: Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            compositeIndexInEditing = null;
                          });
                          closeEndDrawer();
                        },
                      ),
                    ],
                  ),
            // RELATIONSHIP PATHS EDITING
            pathIndexInEditing == null
                ? Container()
                : ListView(
                    shrinkWrap: true,
                    primary: false,
                    padding: ThemeConstant.padding8(),
                    children: [
                      Text("From"),
                      ThemeConstant.sizedBox8,
                      Builder(builder: (context) {
                        int compositeNamesCount = possibleCompositeNames().length;
                        return Wrap(
                          spacing: 5.0,
                          children: List<Widget>.generate(
                            compositeNamesCount,
                            (int index) {
                              String compositeName = possibleCompositeNames()[index];
                              if (pathIndexInEditing == null) {
                                return Container();
                              }
                              var (pathSetIndex, pathInnerIndex) = pathIndexInEditing!;
                              return ChoiceChip(
                                showCheckmark: true,
                                label: Text(possibleCompositeNames()[index]),
                                selected: paths[pathSetIndex][pathInnerIndex].from.contains(compositeName),
                                onSelected: (bool selected) {
                                  if (selected == false) {
                                    paths[pathSetIndex][pathInnerIndex].from.remove(compositeName);
                                  } else {
                                    paths[pathSetIndex][pathInnerIndex].from.add(compositeName);
                                  }
                                  setState(() {});
                                },
                              );
                            },
                          ).toList(),
                        );
                      }),
                      ThemeConstant.sizedBox16,
                      Text("To"),
                      ThemeConstant.sizedBox8,
                      Builder(builder: (context) {
                        if (pathIndexInEditing == null) {
                          return Container();
                        }
                        int compositeNamesCount = possibleCompositeNames().length;
                        return Wrap(
                          spacing: 5.0,
                          children: List<Widget>.generate(
                            compositeNamesCount,
                            (int index) {
                              String compositeName = possibleCompositeNames()[index];

                              var (pathSetIndex, pathInnerIndex) = pathIndexInEditing!;

                              return ChoiceChip(
                                showCheckmark: true,
                                label: Text(possibleCompositeNames()[index]),
                                selected: paths[pathSetIndex][pathInnerIndex].to.contains(compositeName),
                                onSelected: (bool selected) {
                                  List<String> toList = paths[pathSetIndex][pathInnerIndex].to;
                                  print("$selected for ($pathSetIndex, $pathInnerIndex) = pathIndexInEditing!");

                                  if (selected == false) {
                                    toList.remove(compositeName);
                                  } else {
                                    toList.add(compositeName);
                                  }
                                  setState(() {
                                    paths[pathSetIndex][pathInnerIndex].to = toList;
                                  });
                                },
                              );
                            },
                          ).toList(),
                        );
                      }),
                      ThemeConstant.sizedBox16,
                      TextButton.icon(
                        label: Text("Save"),
                        icon: Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            pathIndexInEditing = null;
                          });
                          closeEndDrawer();
                        },
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  Widget eachPathEditing(int pathSetIndex) {
    List<RelationshipPath> innerPaths = paths[pathSetIndex];

    return Padding(
      padding: ThemeConstant.padding16(vertical: true, horizontal: false),
      child: makeSection([
        Row(children: [
          makeSectionTitle("Structural Model #${pathSetIndex + 1}"),
          Spacer(),
          TextButton(
              onPressed: () {
                paths[pathSetIndex].add(RelationshipPath(from: [], to: []));
                pathIndexInEditing = (pathSetIndex, paths[pathSetIndex].length - 1);
                compositeIndexInEditing = null;
                setState(() {});
                openEndDrawer();
              },
              child: Text("+ Add Paths")),
        ]),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          itemCount: innerPaths.length,
          itemBuilder: (BuildContext context, int pathInnerIndex) {
            return InkWell(
              onTap: () {
                setState(() {
                  pathIndexInEditing = (pathSetIndex, pathInnerIndex);
                  compositeIndexInEditing = null;
                });
                openEndDrawer();
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: pathIndexInEditing == (pathSetIndex, pathInnerIndex)
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Builder(builder: (context) {
                          String finalString = _makePathString((pathSetIndex, pathInnerIndex));
                          return Text(
                            finalString,
                            style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                          );
                        }),
                      ),
                      Icon(Icons.edit),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  void populateTextFieldsFromComposite(int index) {
    _nameController.text = composites[index].name ?? "";
    if (composites[index].isMulti) {
      _prefixController.text = composites[index].multiItem?.prefix ?? "";
      _fromController.text = composites[index].multiItem?.from.toString() ?? "";
      _toController.text = composites[index].multiItem?.to.toString() ?? "";
    } else {
      _singleItemController.text = composites[index].singleItem ?? "";
    }
  }

  String _makePathString((int, int) index) {
    var (pathSetIndex, pathInnerIndex) = index;
    return paths[pathSetIndex][pathInnerIndex].makePathString();
  }

  String makeCompositeCommandString(int index) {
    return composites[index].makeCompositeCommandString();
  }

  String makePredictComparisonCommandString() {
    List<String> constructs = composites.map((Composite composite) {
      return composite.makeCompositeCommandString();
    }).toList();
    String constructStringJoined = constructs.join(", ");

    List<String> pathStrings = paths.mapIndexed((int index, List<RelationshipPath> pathSet) {
      List<String> pathInners = pathSet.map((RelationshipPath path) {
        return path.makePathString();
      }).toList();
      String pathsJoined = pathInners.join(", ");
      return """
          # Model ${index + 1}
          structural_model${index + 1} <- relationships(
            $pathsJoined
          )
          """;
    }).toList();
    String pathStringsJoined = pathStrings.join("\n\n");

    List<String> summarisedStrings = pathStrings.mapIndexed((int index, String str) {
      return """
          # Estimate and summarize the models
          pls_model${index + 1} <- estimate_pls(
            data = corp_rep_data,
            measurement_model = measurement_model,
            structural_model = structural_model${index + 1},
            missing_value = "-99"
          )
          sum_model${index + 1} <- summary(pls_model${index + 1})
          """;
    }).toList();
    String summarisedStringsJoined = summarisedStrings.join("\n\n");

    List<String> iteriaVectorStrings = pathStrings.mapIndexed((int index, String str) {
      return 'sum_model${index + 1}\$it_criteria["$compareFrom", "$compareTo"]';
    }).toList();
    String iteriaVectorStringsJoined = iteriaVectorStrings.join(", ");

    String modelsNames = pathStrings.mapIndexed((int index, String str) {
      return '"Model${index + 1}"';
    }).join(", ");

    String finalString = """
        # Create measurement model
          measurement_model <- constructs(
            $constructStringJoined
          )

          # Create structural models:
          $pathStringsJoined

          # Estimate and summarize the models
          $summarisedStringsJoined

          itcriteria_vector <- c(
            $iteriaVectorStringsJoined
          )

          names(itcriteria_vector) <- c($modelsNames)
          """;

    // debugPrint(finalString);

    return finalString;
  }
}
