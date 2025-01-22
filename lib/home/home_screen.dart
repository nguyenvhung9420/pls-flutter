import 'package:flutter/material.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/home/task_chooser_screen.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
import 'package:pls_flutter/utils.dart';
import 'package:device_type/device_type.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PlsTask {
  String taskCode;
  String name;
  String description;
  PlsTask({required this.taskCode, required this.name, required this.description});
}

class _MyHomePageState extends State<MyHomePage> {
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
        description: 'Description for Item 5'),
    PlsTask(taskCode: 'convergent_validity', name: 'Item 5', description: 'Description for Item 5'),
    PlsTask(taskCode: 'convergent_validity', name: 'Item 5', description: 'Description for Item 5'),
  ];

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
      ]),
    ];
  }

  List<TaskGroup> taskGroups = [];

  String modelExplorationSummary = "";
  List<Map<String, String>> textDataToShow = [];
  PlsTask? selectedTask;

  BootstrapSummary? bootstrapSummary;
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
    SeminrSummary? summary = await PLSRepository().getSummaryPaths(userToken: accessToken!);
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

  void onSelectedTask(PlsTask task) async {
    setState(() => selectedTask = task);
    List<Map<String, String>> textToShow = [];
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
      default:
        textToShow = [];
    }
    setState(() => textDataToShow = textToShow);
  }

  String _getDeviceType(BuildContext context) {
    return DeviceType.getDeviceType(context);
  }

  @override
  Widget build(BuildContext context) {
    String deviceType = _getDeviceType(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(deviceType),
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
                    TextButton(onPressed: () {}, child: Text("Add/Update Dataset")),
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
