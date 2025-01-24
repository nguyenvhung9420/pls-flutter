import 'package:flutter/material.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/predict_models_comparison.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/presentation/file_chooser/file_chooser_screen.dart';
import 'package:pls_flutter/presentation/home/task_chooser_screen.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'package:pls_flutter/presentation/models/pls_task_view.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
import 'package:device_type/device_type.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  String? accessToken;

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
    PlsTask(taskCode: 'discriminant_validity', name: 'Discriminant Validty', description: 'Description for Item 5'),
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
  ];

  String instructions = "";

  @override
  void initState() {
    super.initState();
    _login();

    instructions = """corp_rep_mm <- constructs(
    composite("COMP", multi_items("comp_", 1:3)),
    composite("LIKE", multi_items("like_", 1:3)),
    composite("CUSA", single_item("cusa")),
    composite("CUSL", multi_items("cusl_", 1:3))
  )

  corp_rep_sm <- relationships(
    paths(from = c("COMP", "LIKE"), to = c("CUSA", "CUSL")),
    paths(from = c("CUSA"), to = c("CUSL"))
  )

  corp_rep_pls_model <- estimate_pls(
    data = corp_rep_data,
    measurement_model = corp_rep_mm,
    structural_model = corp_rep_sm,
    inner_weights = path_weighting,
    missing = mean_replacement,
    missing_value = "-99"
  )""";

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
  BootstrapSummary? significanceRelevanceOfIndicatorWeights;
  SeminrSummary? seminrSummary;

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
    SeminrSummary? summary = await PLSRepository().getSummaryPaths(userToken: accessToken!, instructions: instructions);
    setState(() => seminrSummary = summary);
    return summary?.getSummaryList() ?? [];
  }

  Future<List<Map<String, String>>> _addBootstrapSummary() async {
    if (accessToken == null) return [];
    BootstrapSummary? summary = await PLSRepository().getBoostrapSummary(userToken: accessToken!);
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

  Future<List<Map<String, String>>> _addDiscriminantValidity() async {
    if (seminrSummary == null) await _addSummaryPaths();
    if (bootstrapSummary == null) await _addBootstrapSummary();
    List<Map<String, String>> toReturn = seminrSummary?.validity?.getValidityList() ?? [];
    toReturn.add({"name": "Bootstraped HTMT", "value": bootstrapSummary?.bootstrappedHtmt?.join("\n") ?? ""});
    return toReturn;
  }

  // getSignificanceRelevanceOfIndicatorWeights
  Future<List<Map<String, String>>> _addSignificanceRelevanceOfIndicatorWeights() async {
    if (accessToken == null) return [];
    BootstrapSummary? summary =
        await PLSRepository().getSignificanceRelevanceOfIndicatorWeights(userToken: accessToken!);
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
    await _addSummaryPaths();
    await _addBootstrapSummary();

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

  // Explanatory power
  Future<List<Map<String, String>>> _addPredictivePower() async {
    List<Map<String, String>> toReturn = [];
    toReturn.add({"name": "Inspect prediction errors", "value": "WIP"});

    return toReturn;
  }

  // Predictive model comparisons
  Future<List<Map<String, String>>> _addPredictiveModelComparisons() async {
    List<Map<String, String>> toReturn = [];

    PredictModelsComparison? predict = await PLSRepository().getComparePredictModels(userToken: accessToken!);

    toReturn.add({
      "name": "Predictive model comparisons - itcriteria weights",
      "value": predict?.itcriteriaVector?.join("\n") ?? ""
    });

    return toReturn;
  }

  // Mediation analysis
  Future<List<Map<String, String>>> _addMediationAnalysis() async {
    List<Map<String, String>> toReturn = [];
    if (seminrSummary == null) await _addSummaryPaths();
    if (bootstrapSummary == null) await _addBootstrapSummary();

    toReturn.add({
      "name": "Total Effects",
      "value": seminrSummary?.totalEffects?.join("\n") ?? "",
    });
    toReturn.add({
      "name": "Total Indirect Effects",
      "value": seminrSummary?.totalIndirectEffects?.join("\n") ?? "",
    });
    toReturn.add({
      "name": "Paths",
      "value": seminrSummary?.paths?.join("\n") ?? "",
    });
    toReturn.add({
      "name": "Bootstrapped Paths",
      "value": bootstrapSummary?.bootstrappedPaths?.join("\n") ?? "",
    });
    return toReturn;
  }

  Future<List<Map<String, String>>> _addModerationAnalysis() async {
    if (accessToken == null) return [];
    BootstrapSummary? summary = await PLSRepository().getModerationAnalysis(userToken: accessToken!);
    return [
      {
        "name": "Bootstraped Paths",
        "value": summary?.bootstrappedPaths?.join("\n") ?? "",
      }
    ];
  }

  void onSelectedTask(PlsTask task) async {
    setState(() => selectedTask = task);
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
        textToShow = await _addPredictivePower();
        break;
      case 'predict_models_comparisons':
        textToShow = await _addPredictiveModelComparisons();
        break;
      case 'mediation_analysis':
        textToShow = await _addMediationAnalysis();
        break;
      case 'moderation_analysis':
        textToShow = await _addModerationAnalysis();
        break;
      default:
        textToShow = [];
    }
    setState(() => textDataToShow = textToShow);
    disableLoading();
  }

  String _getDeviceType(BuildContext context) {
    return DeviceType.getDeviceType(context);
  }

  void _uploadFile(String filePath) async {
    enableLoading();
    if (accessToken == null) return;
    SeminrSummary? summary = await PLSRepository().uploadFile(userToken: accessToken!, filePath: filePath);
    setState(() => seminrSummary = summary);
    disableLoading();
  }

  @override
  Widget build(BuildContext context) {
    String deviceType = _getDeviceType(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(deviceType),
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
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FileChooserScreen(
                                      onDoneWithChoosingFile: (String filePath) {
                                        _uploadFile(filePath);
                                      },
                                    )),
                          );
                        },
                        child: Text("Add/Update Dataset")),
                    Expanded(
                      child: ListView.builder(
                        itemCount: taskGroups.length,
                        itemBuilder: (context, index) {
                          final group = taskGroups[index];
                          return ExpansionTile(
                            initiallyExpanded: true,
                            title: Text(group.name),
                            children: group.tasks.map((PlsTask task) {
                              return ListTile(
                                onTap: () => onSelectedTask(task),
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
                  if (orientation == Orientation.landscape) {
                    // Allow to go on
                  } else {
                    return Container();
                  }
                }
                return Flexible(
                  flex: orientation == Orientation.portrait ? 2 : 3,
                  child: ListView(
                    children: [
                      Text(
                        selectedTask?.name ?? "",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        selectedTask?.description ?? "",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: textDataToShow.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(textDataToShow[index]["name"] ?? ""),
                                subtitle: Text(textDataToShow[index]["value"] ?? ""),
                              ),
                            );
                          }),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
