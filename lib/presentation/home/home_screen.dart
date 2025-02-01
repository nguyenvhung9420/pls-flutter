import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/instruction_maker.dart';
import 'package:pls_flutter/data/models/plot_data.dart';
import 'package:pls_flutter/data/models/predict_models_comparison.dart';
import 'package:pls_flutter/data/models/predict_summary.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/data/models/specific_effect_significance.dart';
import 'package:pls_flutter/presentation/file_chooser/file_chooser_screen.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'package:pls_flutter/presentation/mediation_analysis/mediation_analysis_screen.dart';
import 'package:pls_flutter/presentation/moderation_analysis/formative_convergent_validity_screen.dart';
import 'package:pls_flutter/presentation/structural_model_eval/prediction_comparisons.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/presentation/models/pls_task_view.dart';
import 'package:pls_flutter/presentation/plot/pls_seminr_plot.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
import 'package:device_type/device_type.dart';
import 'package:pls_flutter/utils/theme_constant.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  String? accessToken;
  ConfiguredModel? configuredModel;
  String? graphvizData;

  final List<PlsTask> plsTaskList = [
    PlsTask(
      taskCode: 'model_summary',
      name: 'Model Summary',
      description: 'Serve as basis for the assessment of the measurement and structural model',
    ),
    PlsTask(
      taskCode: 'model_bootstrap_summary',
      name: 'Bootstrap Summary',
      description: 'Perform bootstrapping to estimate standard errors and compute confidence intervals',
    ),
    PlsTask(
      taskCode: 'indicator_reliability',
      name: 'Indicator reliability',
      description: 'Indicator reliability can be calculated by squaring the loadings.',
    ),
    PlsTask(
      taskCode: 'internal_consistency_reliability',
      name: 'Internal consistency reliability',
      description: 'The extent to which indicators measuring the same construct are associated with each other',
    ),
    PlsTask(taskCode: 'convergent_validity', name: 'Convergent Validity', description: 'Description for Item 5'),
    PlsTask(taskCode: 'discriminant_validity', name: 'Discriminant Validity', description: 'Description for Item 5'),
    PlsTask(
        taskCode: 'evaluation_of_formative_basic',
        name: 'Model and measurement details',
        description: 'Model and measurement details'),
    PlsTask(
      taskCode: 'formative_indicator_collinearity',
      name: 'Indicator collinearity',
      description: 'Indicator collinearity',
    ),
    PlsTask(
      taskCode: 'formative_significance_relevance',
      name: 'Significance and relevance of the indicator weights',
      description: 'Significance and relevance of the indicator weights',
    ),
    PlsTask(
      taskCode: 'collinearity_issues',
      name: 'Collinearity issues',
      description:
          'To examine the VIF values for the predictor constructs we inspect the vif_antecedents element within the summary_corp_rep_ext object. ',
    ),

    // Significance and relevance of the structural model relationships;
    PlsTask(
      taskCode: 'structural_significance_relevance',
      name: 'Significance and relevance of the structural model relationships',
      description:
          'To evaluate the relevance and significance of the structural paths, we inspect the bootstrapped_paths element nested',
    ),

    // Explanatory power:
    PlsTask(
      taskCode: 'explanatory_power',
      name: 'Explanatory power',
      description:
          'To consider the model\'s explanatory power we analyze the R2 of the endogenous constructs and the f2 effect size of the predictor constructs. R2 and adjusted R2 can be obtained from the paths element',
    ),

    // Predictive power
    PlsTask(
        taskCode: 'predictive_power',
        name: 'Predictive power',
        description:
            'To evaluate the model\'s predictive power, we generate the predictions using the predict_pls() function'),

    //Predictive model comparisons :
    PlsTask(
      taskCode: 'predict_models_comparisons',
      name: 'Predictive model comparisons',
      description: 'Description',
    ),

    // Mediation analysis
    PlsTask(
        taskCode: 'mediation_analysis',
        name: 'Mediation analysis',
        description:
            'Mediation occurs when a construct, referred to as mediator construct, intervenes between two other related constructs'),

    // Moderation analysis
    PlsTask(
        taskCode: 'moderation_analysis',
        name: 'Moderation analysis',
        description:
            'Moderation describes a situation in which the relationship between two constructs is not constant but depends on the values of a third variable, referred to as a moderator variable'),

    // Formative Convergent Validity:
    PlsTask(
      taskCode: 'formative_convergent_validity',
      name: 'Convergent Validity',
      description: 'Convergent Validity',
    ),
  ];

  String instructions = "";

  String makeInstructions({required ConfiguredModel model}) {
    return InstructionMaker.makeInstructions(model: configuredModel!);
  }

  @override
  void initState() {
    super.initState();
    _login();

    taskGroups = [
      TaskGroup('Model Setup', [
        plsTaskList[0],
        plsTaskList[1],
      ]),
      TaskGroup('Evaluation of reflective measurement models', [
        plsTaskList[2],
        plsTaskList[3],
        plsTaskList[4],
        plsTaskList[5],
      ]),
      TaskGroup('Evaluation of formative measurement models', [
        plsTaskList[6],
        plsTaskList[16],
        plsTaskList[7],
        plsTaskList[8],
      ]),
      TaskGroup('Evaluation of the structural model', [
        plsTaskList[9],
        plsTaskList[10],
        plsTaskList[11],
        plsTaskList[12],
        plsTaskList[13],
      ]),
      TaskGroup("Mediation analysis", [
        plsTaskList[14],
      ]),
      TaskGroup("Moderation analysis", [
        plsTaskList[15],
      ])
    ];
  }

  List<TaskGroup> taskGroups = [];

  String modelExplorationSummary = "";
  List<Map<String, String>> textDataToShow = [];
  PlsTask? selectedTask;

  BootstrapSummary? bootstrapSummary;
  PredictSummary? predictSummary;
  BootstrapSummary? significanceRelevanceOfIndicatorWeights;
  SeminrSummary? seminrSummary;
  SpecificEffectSignificance? specificEffectSignificance;

  dynamic dataBytes;

  void _login() async {
    accessToken = await AuthTokenRepository().getCurrentAuthToken();

    if (accessToken?.isEmpty == false) {
      setState(() => accessToken = accessToken);
      return;
    }

    accessToken = await AuthRepository().login(loginBody: {"username": "hungnguyen_pls_sem", "password": "secret"});

    if (accessToken != null) {
      await AuthTokenRepository().saveAuthToken(token: accessToken!);
      setState(() => accessToken = accessToken);
    }
  }

  Future<List<Map<String, String>>> _addSummaryPaths() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    // if (seminrSummary?.getSummaryList().isNotEmpty ?? false) return seminrSummary?.getSummaryList() ?? [];

    SeminrSummary? summary = await PLSRepository().getSummaryPaths(
      userToken: accessToken!,
      instructions: makeInstructions(model: configuredModel!),
      filePath: configuredModel!.filePath,
    );
    setState(() => seminrSummary = summary);
    return summary?.getSummaryList() ?? [];
  }

  Future<List<Map<String, String>>> _addBootstrapSummary() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    // if (bootstrapSummary?.getBootstrapSummaryList().isNotEmpty ?? false) {
    //   return bootstrapSummary?.getBootstrapSummaryList() ?? [];
    // }

    BootstrapSummary? summary = await PLSRepository().getBoostrapSummary(
      userToken: accessToken!,
      instructions: makeInstructions(model: configuredModel!),
      filePath: configuredModel!.filePath,
    );
    setState(() => bootstrapSummary = summary);
    return summary?.getBootstrapSummaryList() ?? [];
  }

  Future<List<Map<String, String>>> _addIndicatorReliability() async {
    if (seminrSummary == null) await _addSummaryPaths();
    Map<String, String> loadings = {
      "name": "Loadings",
      "value": seminrSummary?.loadings?.join("\n") ?? "",
    };
    Map<String, String> loadingsSquared = {
      "name": "Loadings^2",
      "value": seminrSummary?.loadingsSquared?.join("\n") ?? ""
    };
    return [loadings, loadingsSquared];
  }

  Future<List<Map<String, String>>> _addInternalConsistentReliability() async {
    if (seminrSummary == null) await _addSummaryPaths();
    Map<String, String> reliability = {
      "name": "Reliability",
      "value": seminrSummary?.reliability?.join("\n") ?? "",
    };

    return [reliability];
  }

  Future<List<Map<String, String>>> _addConvergentValidity() async {
    if (seminrSummary == null) await _addSummaryPaths();
    Map<String, String> reliability = {
      "name": "Reliability",
      "value": seminrSummary?.reliability?.join("\n") ?? "",
    };

    return [reliability];
  }

  Future<List<Map<String, String>>> _addFormativeConvergentValidity() async {
    return [];
  }

  Future<List<Map<String, String>>> _addDiscriminantValidity() async {
    if (seminrSummary == null) await _addSummaryPaths();
    if (bootstrapSummary == null) await _addBootstrapSummary();
    List<Map<String, String>> toReturn = seminrSummary?.validity?.getValidityList() ?? [];
    toReturn.add({"name": "Bootstraped HTMT", "value": bootstrapSummary?.bootstrappedHtmt?.join("\n") ?? ""});
    return toReturn;
  }

  // getSignificanceRelevanceOfIndicatorWeights
  Future<List<Map<String, String>>> _addSignificanceRelevanceOfIndicatorWeights() async {
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    if (accessToken == null) return [];

    BootstrapSummary? summary = await PLSRepository().getSignificanceRelevanceOfIndicatorWeights(
      userToken: accessToken!,
      instructions: makeInstructions(model: configuredModel!),
      filePath: configuredModel!.filePath,
    );
    setState(() => significanceRelevanceOfIndicatorWeights = summary);
    return [
      {
        "name": "Bootstraped Weights",
        "value": significanceRelevanceOfIndicatorWeights?.bootstrappedWeights?.join("\n") ?? "",
      },
      {
        "name": "Bootstraped Loadings",
        "value": significanceRelevanceOfIndicatorWeights?.bootstrappedLoadings?.join("\n") ?? "",
      },
    ];
  }

  //Reflective Measurement Model Evaluation
  Future<List<Map<String, String>>> _addReflectiveMeasurementModelEval() async {
    if (seminrSummary == null) await _addSummaryPaths();
    if (bootstrapSummary == null) await _addBootstrapSummary();

    List<Map<String, String>> toReturn = [
      {
        "name": "Indicator reliability - Loadings",
        "value": seminrSummary?.loadings?.join("\n") ?? "",
      },
      {
        "name": "Indicator reliability - Loadings^2",
        "value": seminrSummary?.loadingsSquared?.join("\n") ?? "",
      },
      {
        "name": "Internal consistence reliability and convergent validity - Fornell-Larcker criterion",
        "value": seminrSummary?.validity?.flCriteria?.join("\n") ?? "",
      },
      {
        "name":
            "Internal consistence reliability and convergent validity - Heterotrait-monotrait ratio (HTMT) of the correlations",
        "value": seminrSummary?.validity?.htmt?.join("\n") ?? "",
      },
      {
        "name": "Internal consistence reliability and convergent validity - Bootstrapped HTMT",
        "value": bootstrapSummary?.bootstrappedHtmt?.join("\n") ?? "",
      },
    ];
    return toReturn;
  }

  Future<List<Map<String, String>>> _addFormativeIndicatorCollinear() async {
    if (seminrSummary == null) await _addSummaryPaths();
    List<Map<String, String>> toReturn = [
      {
        "name": "Formative indicator collinearity - VIF",
        "value": seminrSummary?.validity?.vifItems?.join("\n") ?? "",
      },
    ];
    return toReturn;
  }

  Future<List<Map<String, String>>> _addCollinearityIssues() async {
    if (seminrSummary == null) await _addSummaryPaths();
    List<Map<String, String>> toReturn = [
      {
        "name": "Collinearity issues - VIF Antecedents",
        "value": seminrSummary?.vifAntecedents?.join("\n") ?? "",
      },
    ];
    return toReturn;
  }

  // Significance and relevance of the structural model relationships
  Future<List<Map<String, String>>> _addSignificanceRelevanceOfRelationships() async {
    if (bootstrapSummary == null) await _addBootstrapSummary();
    List<Map<String, String>> toReturn = [];
    toReturn.add({"name": "Bootstraped Paths", "value": bootstrapSummary?.bootstrappedPaths?.join("\n") ?? ""});
    toReturn
        .add({"name": "Bootstraped Total Paths", "value": bootstrapSummary?.bootstrappedTotalPaths?.join("\n") ?? ""});
    return toReturn;
  }

  // Explanatory power
  Future<List<Map<String, String>>> _addExplanatoryPower() async {
    if (seminrSummary == null) await _addSummaryPaths();
    List<Map<String, String>> toReturn = [];
    toReturn.add({"name": "Paths", "value": seminrSummary?.paths?.join("\n") ?? ""});
    toReturn.add({"name": "F Squared", "value": seminrSummary?.fSquare?.join("\n") ?? ""});
    return toReturn;
  }

  // Get general model prediction:
  Future<List<Map<String, String>>> _addGeneralModelPrediction() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];

    PredictSummary? summary = await PLSRepository().getGeneralPrediction(
      userToken: accessToken!,
      instructions: makeInstructions(model: configuredModel!),
      filePath: configuredModel!.filePath,
    );
    setState(() => predictSummary = summary);
    return [
      {"name": "Prediction Summary", "value": summary?.predictSummary?.join("\n") ?? ""},
    ];
  }

  Future<List<Map<String, String>>> _addModerationAnalysis() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    BootstrapSummary? summary = await PLSRepository().getModerationAnalysis(
        userToken: accessToken!,
        filePath: configuredModel!.filePath,
        instructions: makeInstructions(model: configuredModel!));
    return [
      {
        "name": "Bootstrapped Paths",
        "value": summary?.bootstrappedPaths?.join("\n") ?? "",
      }
    ];
  }

  Future<String?> _getPlotPLSModel() async {
    if (accessToken == null) return null;
    if (configuredModel == null) return null;
    if (configuredModel?.filePath == null) null;

    PlotData? graphvizData = await PLSRepository().getConceptualModelPlot(
        userToken: accessToken!,
        filePath: configuredModel!.filePath,
        instructions: makeInstructions(model: configuredModel!));
    setState(() {
      this.graphvizData = graphvizData?.plotData?.join("\n");
    });
    return this.graphvizData;
  }

  void onSelectedTask({required PlsTask task, required bool isOnPhone}) async {
    showSnackBar(message: "${task.name} requested. Please wait!");

    setState(() => selectedTask = task);
    setState(() => textDataToShow = []);
    List<Map<String, String>> textToShow = [];

    enableLoading();
    switch (task.taskCode) {
      case 'model_summary':
        textToShow = await _addSummaryPaths();
        break;
      case 'model_bootstrap_summary':
        textToShow = await _addBootstrapSummary();
        break;
      case 'indicator_reliability':
        textToShow = await _addIndicatorReliability();
        break;
      case 'internal_consistency_reliability':
        textToShow = await _addInternalConsistentReliability();
        break;
      case 'convergent_validity':
        textToShow = await _addConvergentValidity();
        break;
      case 'discriminant_validity':
        textToShow = await _addDiscriminantValidity();
        break;
      case 'evaluation_of_formative_basic':
        textToShow = await _addReflectiveMeasurementModelEval();
        break;
      case 'formative_convergent_validity':
        textToShow = await _addFormativeConvergentValidity();
        break;
      case 'formative_indicator_collinearity':
        textToShow = await _addFormativeIndicatorCollinear();
        break;
      case 'formative_significance_relevance':
        textToShow = await _addSignificanceRelevanceOfIndicatorWeights();
        break;
      case 'collinearity_issues':
        textToShow = await _addCollinearityIssues();
        break;
      case 'structural_significance_relevance':
        textToShow = await _addSignificanceRelevanceOfRelationships();
        break;
      case 'explanatory_power':
        textToShow = await _addExplanatoryPower();
        break;
      case 'predictive_power':
        textToShow = await _addGeneralModelPrediction();
        break;
      case 'predict_models_comparisons':
        break;
      case 'mediation_analysis':
        break;
      case 'moderation_analysis':
        textToShow = await _addModerationAnalysis();
        break;
      default:
        textToShow = [];
    }
    setState(() => textDataToShow = textToShow);
    setState(() {});
    disableLoading();

    if (isOnPhone) {
      switch (task.taskCode) {
        case 'predict_models_comparisons':
          if (accessToken == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ComparePredictionsScreen(
                accessToken: accessToken!,
                configuredModel: configuredModel,
                onDoneWithModelSetup: (ConfiguredModel model) {},
              ),
            ),
          );
        case 'formative_convergent_validity':
          if (configuredModel == null) {
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => FormativeConvergentValidityScreen(filePath: configuredModel!.filePath)),
          );

        default:
          showBaseBottomSheet(
            proportionWithSreenHeight: 0.9,
            context: context,
            child: buildCalculationResult(),
          );
      }
    }
  }

  String _getDeviceType(BuildContext context) {
    return DeviceType.getDeviceType(context);
  }

  void _saveModelSetup(ConfiguredModel model) async {
    setState(() => configuredModel = model);
  }

  @override
  Widget build(BuildContext context) {
    String deviceType = _getDeviceType(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("PLS SEM"),
        elevation: 1,
        // bottom: defaultLinearProgressBar(context),
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Row(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: ThemeConstant.padding8(),
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FileChooserScreen(
                                        onDoneWithModelSetup: (ConfiguredModel model) => _saveModelSetup(model),
                                        configuredModel: configuredModel,
                                      )),
                            );
                          },
                          icon: Icon(Icons.document_scanner_outlined),
                          label: Text(configuredModel == null ? "Add Dataset" : "Update Dataset"),
                        ),
                      ),
                    ),
                    configuredModel == null
                        ? Container()
                        : ExpansionTile(
                            initiallyExpanded: false,
                            title: Text("Plot current model"),
                            children: [
                              ListTile(
                                onTap: () async {
                                  String? plotData = await _getPlotPLSModel();
                                  if (plotData == null) {
                                    debugPrint("No plot data");
                                    return;
                                  }
                                  debugPrint("Plot data: $plotData");
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PlsSeminrPlot(
                                            graphVizString: plotData,
                                            plotProvider: "https://dreampuf.github.io/GraphvizOnline/?engine=dot#",
                                          )));
                                },
                                leading: Icon(Icons.graphic_eq),
                                title: Text("Editable plot (dreampuf.com)"),
                              ),
                              ListTile(
                                onTap: () async {
                                  String? plotData = await _getPlotPLSModel();
                                  if (plotData == null) {
                                    debugPrint("No plot data");
                                    return;
                                  }
                                  debugPrint("Plot data: $plotData");
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PlsSeminrPlot(
                                            graphVizString: plotData,
                                            plotProvider: "https://quickchart.io/graphviz?graph=",
                                          )));
                                },
                                leading: Icon(Icons.graphic_eq),
                                title: Text("Read-only plot (quickchart.io)"),
                              ),
                            ],
                          ),
                    Expanded(
                      child: configuredModel == null
                          ? Padding(
                              padding: ThemeConstant.padding16(),
                              child: Text("Please add a data set and build its models first"))
                          : ListView.builder(
                              itemCount: taskGroups.length,
                              itemBuilder: (context, index) {
                                final group = taskGroups[index];
                                return ExpansionTile(
                                  initiallyExpanded: true,
                                  title: Text(group.name),
                                  children: group.tasks.map((PlsTask task) {
                                    return ListTile(
                                      onTap: () => onSelectedTask(task: task, isOnPhone: deviceType != "Tablet"),
                                      leading: Icon(Icons.task),
                                      title: Text(task.name),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (deviceType != "Tablet") {
                  return Container();
                }
                return Flexible(
                  flex: orientation == Orientation.portrait ? 2 : 3,
                  child: buildCalculationResult(),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget buildCalculationResult() {
    return Builder(builder: (context) {
      switch (selectedTask?.taskCode) {
        case 'formative_convergent_validity':
          if (configuredModel == null) {
            return Container();
          }
          return FormativeConvergentValidityScreen(filePath: configuredModel!.filePath);
        case 'predict_models_comparisons':
          if (accessToken == null) {
            return Container();
          }
          return ComparePredictionsScreen(
            accessToken: accessToken!,
            configuredModel: configuredModel,
            onDoneWithModelSetup: (ConfiguredModel model) {},
          );
        case 'mediation_analysis':
          if (accessToken == null || configuredModel == null) {
            return Container();
          }
          return MediationAnalysisScreen(
              accessToken: accessToken!,
              seminrSummary: seminrSummary,
              filePath: configuredModel?.filePath,
              configuredmodel: configuredModel,
              bootstrapSummary: bootstrapSummary);
        default:
          return ListView(
            padding: ThemeConstant.padding16(),
            children: [
              makeBottomSheetTitle(selectedTask?.name ?? ""),
              ThemeConstant.sizedBox16,
              loadingNotice(),
              ThemeConstant.sizedBox16,
              ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: textDataToShow.length,
                  itemBuilder: (context, index) => Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: ThemeConstant.padding8(),
                          child: ListTile(
                            title: Text(
                              textDataToShow[index]["name"] ?? "",
                              style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                            ),
                            subtitle: Text(
                              textDataToShow[index]["value"] ?? "",
                              style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                            ),
                          ),
                        ),
                      )),
            ],
          );
      }
    });
  }
}
