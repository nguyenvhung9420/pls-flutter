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
import 'package:pls_flutter/presentation/home/home_viewmodel.dart';
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
  MyHomeViewModel viewModel = MyHomeViewModel();
  String? accessToken;
  ConfiguredModel? configuredModel;
  String? graphvizData;
  String instructions = "";
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

  void clearSummaryData() {
    bootstrapSummary = null;
    predictSummary = null;
    significanceRelevanceOfIndicatorWeights = null;
    seminrSummary = null;
    specificEffectSignificance = null;
    dataBytes = null;
    graphvizData = null;
    textDataToShow = [];
    setState(() {});
  }

  String makeInstructions({required ConfiguredModel model}) {
    return InstructionMaker.makeInstructions(model: configuredModel!);
  }

  @override
  void initState() {
    super.initState();
    _login();
    taskGroups = viewModel.taskGroups();
  }

  void _login() async {
    accessToken = await AuthTokenRepository().getCurrentAuthToken();

    if (accessToken?.isEmpty == false) {
      setState(() => accessToken = accessToken);
      return;
    }
    try {
      accessToken = await AuthRepository().login(loginBody: viewModel.loginCredentials);
      if (accessToken != null) {
        await AuthTokenRepository().saveAuthToken(token: accessToken!);
        setState(() => accessToken = accessToken);
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get access token");
    }
  }

  Future<List<Map<String, String>>> _addSummaryPaths() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    if (seminrSummary != null) return seminrSummary?.getSummaryList() ?? [];

    try {
      SeminrSummary? summary = await PLSRepository().getSummaryPaths(
        userToken: accessToken!,
        instructions: makeInstructions(model: configuredModel!),
        filePath: configuredModel!.filePath,
      );
      setState(() => seminrSummary = summary);
      return summary?.getSummaryList() ?? [];
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get model summary");
      return [];
    }
  }

  Future<List<Map<String, String>>> _addBootstrapSummary() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    if (bootstrapSummary != null) return bootstrapSummary?.getBootstrapSummaryList() ?? [];

    try {
      BootstrapSummary? summary = await PLSRepository().getBoostrapSummary(
        userToken: accessToken!,
        instructions: makeInstructions(model: configuredModel!),
        filePath: configuredModel!.filePath,
      );
      setState(() => bootstrapSummary = summary);
      return summary?.getBootstrapSummaryList() ?? [];
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get bootstrap summary");
      return [];
    }
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

    try {
      List<Map<String, String>> toReturn = seminrSummary?.validity?.getValidityList() ?? [];
      toReturn.add({"name": "Bootstraped HTMT", "value": bootstrapSummary?.bootstrappedHtmt?.join("\n") ?? ""});
      return toReturn;
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get discriminant validity");
      return [];
    }
  }

  // getSignificanceRelevanceOfIndicatorWeights
  Future<List<Map<String, String>>> _addSignificanceRelevanceOfIndicatorWeights() async {
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];
    if (accessToken == null) return [];

    BootstrapSummary? summary;
    try {
      if (significanceRelevanceOfIndicatorWeights == null) {
        summary = await PLSRepository().getSignificanceRelevanceOfIndicatorWeights(
          userToken: accessToken!,
          instructions: makeInstructions(model: configuredModel!),
          filePath: configuredModel!.filePath,
        );
        setState(() => significanceRelevanceOfIndicatorWeights = summary);
      }
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
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get significance relevance of indicator weights");
      return [];
    }
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

    try {
      if (predictSummary == null) {
        PredictSummary? summary = await PLSRepository().getGeneralPrediction(
          userToken: accessToken!,
          instructions: makeInstructions(model: configuredModel!),
          filePath: configuredModel!.filePath,
        );
        setState(() => predictSummary = summary);
      }
      return [
        {"name": "Prediction Summary", "value": predictSummary?.predictSummary?.join("\n") ?? ""},
      ];
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get general model prediction");
      return [];
    }
  }

  Future<List<Map<String, String>>> _addModerationAnalysis() async {
    if (accessToken == null) return [];
    if (configuredModel == null) return [];
    if (configuredModel?.filePath == null) return [];

    try {
      BootstrapSummary? summary = await PLSRepository().getModerationAnalysis(
          userToken: accessToken!,
          filePath: configuredModel!.filePath,
          instructions: makeInstructions(model: configuredModel!));
      return [
        {"name": "Bootstrapped Paths", "value": summary?.bootstrappedPaths?.join("\n") ?? ""}
      ];
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get moderation analysis");
      return [];
    }
  }

  Future<String?> _getPlotPLSModel() async {
    if (accessToken == null) return null;
    if (configuredModel == null) return null;
    if (configuredModel?.filePath == null) null;

    try {
      if (graphvizData == null) {
        PlotData? graphviz = await PLSRepository().getConceptualModelPlot(
            userToken: accessToken!,
            filePath: configuredModel!.filePath,
            instructions: makeInstructions(model: configuredModel!));
        setState(() {
          graphvizData = graphviz?.plotData?.join("\n");
        });
      }
      return graphvizData;
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(message: "Unexpected error: Cannot get plot for the PLS model");
      return null;
    }
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

  void _gotoFileChooserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FileChooserScreen(
                onDoneWithModelSetup: (ConfiguredModel model) => _saveModelSetup(model),
                configuredModel: configuredModel,
              )),
    );
  }

  void _goToPlotData({required bool editable, required BuildContext context}) async {
    String? plotData = await _getPlotPLSModel();
    if (plotData == null) {
      debugPrint("No plot data");
      return;
    }
    debugPrint("Plot data: $plotData");
    if (editable) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PlsSeminrPlot(
                graphVizString: plotData,
                plotProvider: "https://dreampuf.github.io/GraphvizOnline/?engine=dot#",
              )));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlsSeminrPlot(
              graphVizString: plotData,
              plotProvider: "https://quickchart.io/graphviz?graph=",
            )));
  }

  bool dataIsReady() {
    return (configuredModel != null) &&
        (configuredModel?.composites.isNotEmpty ?? false) &&
        (configuredModel?.paths.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    String deviceType = _getDeviceType(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("PLS SEM"),
        elevation: 1,
        bottom: defaultLinearProgressBar(context),
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
                          onPressed: () => _gotoFileChooserScreen(),
                          icon: Icon(Icons.document_scanner_outlined),
                          label: Text(configuredModel == null ? "Add Dataset" : "Update Dataset"),
                        ),
                      ),
                    ),
                    dataIsReady() == false
                        ? Container()
                        : ExpansionTile(
                            initiallyExpanded: false,
                            title: Text("Plot current model"),
                            children: [
                              ListTile(
                                onTap: () => _goToPlotData(editable: true, context: context),
                                leading: Icon(Icons.bar_chart_outlined),
                                title: Text("Editable plot (dreampuf.com)"),
                              ),
                              ListTile(
                                onTap: () => _goToPlotData(editable: false, context: context),
                                leading: Icon(Icons.bar_chart_outlined),
                                title: Text("Read-only plot (quickchart.io)"),
                              ),
                            ],
                          ),
                    Expanded(
                      child: dataIsReady() == false
                          ? Padding(
                              padding: ThemeConstant.padding16(),
                              child: Builder(builder: (context) {
                                if (configuredModel?.composites.isEmpty == true) {
                                  return Text(
                                      "Your measurement model is incomplete. Please press Update to update your model.");
                                } else if (configuredModel?.paths.isEmpty == true) {
                                  return Text(
                                      "Your structural model is incomplete. Please press Update to update your model.");
                                }
                                return Text("Please add a data set and build its models first");
                              }),
                            )
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
