import 'package:device_type/device_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/redundancy_model.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'package:pls_flutter/presentation/base_state/pls_textfield.dart';
import 'package:pls_flutter/presentation/file_chooser/file_chooser_screen.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/presentation/models/pls_task_view.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
import 'package:pls_flutter/repositories/prepared_setups/predefined_redundancy_models.dart';
import 'package:pls_flutter/utils/theme_constant.dart';

class FormativeConvergentValidityScreen extends StatefulWidget {
  final String filePath;
  const FormativeConvergentValidityScreen({super.key, required this.filePath});

  @override
  State<FormativeConvergentValidityScreen> createState() => _FormativeConvergentValidityScreenState();
}

class _FormativeConvergentValidityScreenState extends BaseState<FormativeConvergentValidityScreen> {
  String? accessToken;
  PlsTask? selectedTask;
  BootstrapSummary? bootstrapSummary;
  List<SeminrSummary?> seminrSummaries = [];

  List<List<String>> listOfPaths = [];

  List<RedundancyModel> redundancyModels = [];
  int? redundancyModelIndexInEditing;

  @override
  void initState() {
    super.initState();
    _login();
  }

  void _populateTextFieldsFromRedundancyModel(int index) {
    setState(() {
      redundancyModelIndexInEditing = index;
    });
    RedundancyModel redundancyModel = redundancyModels[index];
    _modelNameController.text = redundancyModel.name;

    _formativeNameController.text = redundancyModel.compositeForFormative.name ?? "";
    _globalNameController.text = redundancyModel.compositeForGlobal.name ?? "";

    if (redundancyModel.compositeForFormative.isMulti) {
      _multiItemFormativeController.text = redundancyModel.compositeForFormative.multiItem!.prefix;
      _fromController.text = redundancyModel.compositeForFormative.multiItem!.from.toString();
      _toController.text = redundancyModel.compositeForFormative.multiItem!.to.toString();
    } else {
      _singleItemFormativeController.text = redundancyModel.compositeForFormative.singleItem!;
    }

    if (redundancyModel.compositeForGlobal.singleItem != null) {
      _singleItemGlobalController.text = redundancyModel.compositeForGlobal.singleItem!;
    }
  }

  void _addRedundancyModel() {
    redundancyModels.add(RedundancyModel(
        compositeForGlobal: Composite(
          name: "COMP",
          weight: null,
          singleItem: "comp",
          multiItem: null,
          isMulti: false,
          isInteractionTerm: false,
          iv: null,
          moderator: null,
        ),
        compositeForFormative: Composite(
          name: "COMP",
          weight: "mode_B",
          singleItem: null,
          multiItem: MultiItem(prefix: "comp_", from: 1, to: 3),
          isMulti: true,
          isInteractionTerm: false,
          iv: null,
          moderator: null,
        ),
        name: 'Untitled'));
    setState(() {});
  }

  Future<void> _addAllRedundancySummaryPaths() async {
    if (accessToken == null) return;
    enableLoading();
    redundancyModels = [];
    redundancyModels.forEach((RedundancyModel element) async {
      await _addRedundancySummaryPaths(redundancyModel: element);
    });
    disableLoading();
  }

  Future<void> _addRedundancySummaryPaths({required RedundancyModel redundancyModel}) async {
    if (accessToken == null) return;
    enableLoading();
    SeminrSummary? summary = await PLSRepository().getSummaryRedundancyModel(
      userToken: accessToken!,
      instructions: redundancyModel.makeModelString(),
      filePath: widget.filePath,
    );
    seminrSummaries.add(summary);
    setState(() {});
    disableLoading();
  }

  void _populateDataFromModel() {
    redundancyModels = [];
    redundancyModels.addAll(predefinedRedundancyModels);
    setState(() {});
    _addAllRedundancySummaryPaths();
  }

  TextEditingController _modelNameController = TextEditingController();

  TextEditingController _formativeNameController = TextEditingController();
  TextEditingController _globalNameController = TextEditingController();

  TextEditingController _singleItemGlobalController = TextEditingController();
  TextEditingController _multiItemFormativeController = TextEditingController();
  TextEditingController _singleItemFormativeController = TextEditingController();

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  void openEndDrawer() {
    _key.currentState?.openEndDrawer();
  }

  void closeEndDrawer() {
    _key.currentState?.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    String deviceType = _getDeviceType(context);

    return Scaffold(
      key: _key,
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).viewPadding.top, 16, 16),
            children: [
              makeBottomSheetTitle("Convergent Validity of Formative Analysis"),
              SizedBox(height: 24),
              makeSection([
                Row(children: [
                  makeSectionTitle("Redundancy Models"),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      _addRedundancyModel();
                      openEndDrawer();
                    },
                    child: Text("+ Add"),
                  ),
                ]),
                ThemeConstant.sizedBox16,
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: ThemeConstant.padding16(),
                    child:
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text("Do you want to load predefined redundancy models for 'Corporate Reputation Data'?"),
                      Row(
                        children: [
                          Spacer(),
                          TextButton(onPressed: () => _populateDataFromModel(), child: Text("Load Predefined")),
                        ],
                      )
                    ]),
                  ),
                ),
                ThemeConstant.sizedBox16,
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: redundancyModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        _populateTextFieldsFromRedundancyModel(index);
                        openEndDrawer();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: redundancyModelIndexInEditing == index
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Builder(builder: (context) {
                                return Text(redundancyModels[index].name);
                              }),
                              Spacer(),
                              Icon(Icons.edit),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]),
              ThemeConstant.sizedBox16,
              makeSection([
                makeSectionTitle("Convergent Validity via Path Coefficients "),
                ThemeConstant.sizedBox16,
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: seminrSummaries.length,
                  itemBuilder: (BuildContext context, int index) {
                    SeminrSummary summary = seminrSummaries[index]!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: redundancyModelIndexInEditing == index
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          "Paths",
                          style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                        ),
                        subtitle: Text(
                          summary.paths?.join("\n") ?? "",
                          style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                        ),
                      ),
                    );
                  },
                ),
              ])
            ],
          ),
          deviceType == "Tablet"
              ? Container()
              : InkWell(
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
      endDrawer: Drawer(
          width: deviceType == "Tablet"
              ? MediaQuery.of(context).size.width * 0.3
              : MediaQuery.of(context).size.width * 0.9,
          child: ListView(
            children: [
              redundancyModelIndexInEditing == null
                  ? Container()
                  : ListView(
                      shrinkWrap: true,
                      primary: false,
                      padding: ThemeConstant.padding8(),
                      children: [
                        // REDUNDANCY MODEL NAME
                        Container(
                          padding: ThemeConstant.padding16(),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              PLSTextField(
                                controller: _modelNameController,
                                labelText: "Redundancy Model Name",
                                onChanged: (String newVal) {
                                  setState(() =>
                                      redundancyModels[redundancyModelIndexInEditing!].name = newVal.toUpperCase());
                                },
                              ),
                            ],
                          ),
                        ),
                        ThemeConstant.sizedBox16,

                        // FOR EDITING FORMATIVE COMPOSITE
                        Container(
                          padding: ThemeConstant.padding16(),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PLSTextField(
                                controller: _formativeNameController,
                                labelText: "Formative Name",
                                onChanged: (String newVal) {
                                  setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                      .compositeForFormative
                                      .name = newVal);
                                },
                              ),
                              ThemeConstant.sizedBox16,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Is this a multi item?"),
                                  Switch(
                                    value:
                                        redundancyModels[redundancyModelIndexInEditing!].compositeForFormative.isMulti,
                                    onChanged: (bool value) {
                                      setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                          .compositeForFormative
                                          .isMulti = value);
                                    },
                                  ),
                                ],
                              ),
                              ThemeConstant.sizedBox16,
                              Builder(builder: (ctx) {
                                if (redundancyModels[redundancyModelIndexInEditing!].compositeForFormative.isMulti) {
                                  return Column(mainAxisSize: MainAxisSize.min, children: [
                                    PLSTextField(
                                      controller: _multiItemFormativeController,
                                      labelText: "Prefix",
                                      hintText: 'e.g. "cusl_"',
                                      onChanged: (String newVal) {
                                        setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                            .compositeForFormative
                                            .multiItem
                                            ?.prefix = newVal);
                                      },
                                    ),
                                    ThemeConstant.sizedBox8,
                                    PLSTextField(
                                      controller: _fromController,
                                      labelText: "From",
                                      onChanged: (String newVal) {
                                        setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                            .compositeForFormative
                                            .multiItem
                                            ?.from = int.parse(newVal));
                                      },
                                    ),
                                    ThemeConstant.sizedBox8,
                                    PLSTextField(
                                        controller: _toController,
                                        labelText: "To",
                                        onChanged: (String newVal) {
                                          setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                              .compositeForFormative
                                              .multiItem
                                              ?.to = int.parse(newVal));
                                        })
                                  ]);
                                } else {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Single Item Variable"),
                                      SizedBox(height: 5),
                                      PLSTextField(
                                        controller: _singleItemFormativeController,
                                        labelText: "Variable Name",
                                        onChanged: (String newVal) {
                                          setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                              .compositeForFormative
                                              .singleItem = newVal);
                                        },
                                      ),
                                    ],
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                        ThemeConstant.sizedBox16,
                        // FOR EDITING FORMATIVE COMPOSITE:
                        Container(
                          padding: ThemeConstant.padding16(),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              PLSTextField(
                                controller: _globalNameController,
                                labelText: "Global variable Name",
                                onChanged: (String newVal) {
                                  setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                      .compositeForGlobal
                                      .name = newVal);
                                },
                              ),
                              ThemeConstant.sizedBox16,
                              PLSTextField(
                                controller: _singleItemGlobalController,
                                labelText: "Global single-item composite",
                                onChanged: (String newVal) {
                                  setState(() => redundancyModels[redundancyModelIndexInEditing!]
                                      .compositeForGlobal
                                      .singleItem = newVal);
                                },
                              ),
                            ],
                          ),
                        ),
                        ThemeConstant.sizedBox16,
                        Row(
                          children: [
                            TextButton.icon(
                              label: Text("Cancel"),
                              icon: Icon(Icons.close),
                              onPressed: () async {
                                closeEndDrawer();
                              },
                            ),
                            Spacer(),
                            TextButton.icon(
                              label: Text("Save"),
                              icon: Icon(Icons.check),
                              onPressed: () async {
                                await _addAllRedundancySummaryPaths();
                                setState(() {
                                  redundancyModelIndexInEditing = null;
                                });
                                closeEndDrawer();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          )),
    );
  }

  String _getDeviceType(BuildContext context) {
    return DeviceType.getDeviceType(context);
  }

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
}
