import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/instruction_maker.dart';
import 'package:pls_flutter/data/models/redundancy_model.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/data/models/specific_effect_significance.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'package:pls_flutter/presentation/base_state/pls_textfield.dart';
import 'package:pls_flutter/presentation/file_chooser/file_chooser_screen.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/presentation/models/pls_task_view.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
import 'package:pls_flutter/repositories/prepared_setups/predefined_mediation_items.dart';
import 'package:pls_flutter/repositories/prepared_setups/predefined_redundancy_models.dart';
import 'package:pls_flutter/utils/theme_constant.dart';

class MediationAnalysisScreen extends StatefulWidget {
  final String? filePath;
  final String? accessToken;
  final SeminrSummary? seminrSummary;
  final BootstrapSummary? bootstrapSummary;
  final ConfiguredModel? configuredmodel;

  const MediationAnalysisScreen({
    super.key,
    required this.accessToken,
    required this.seminrSummary,
    required this.filePath,
    required this.configuredmodel,
    required this.bootstrapSummary,
  });

  @override
  State<MediationAnalysisScreen> createState() => _MediationAnalysisScreenState();
}

class MediationInput {
  String from;
  String to;
  String through;

  MediationInput({required this.from, required this.to, required this.through});
}

class _MediationAnalysisScreenState extends BaseState<MediationAnalysisScreen> {
  PlsTask? selectedTask;
  BootstrapSummary? bootstrapSummary;
  List<SeminrSummary?> seminrSummaries = [];
  List<List<String>> listOfPaths = [];
  List<MediationInput> mediationInputs = [];
  int? mediationInputInEditing;
  List<Map<String, String>> mediationGeneral = [];
  List<SpecificEffectSignificance?> mediationPerSignificance = [];

  @override
  void initState() {
    super.initState();

    _addMediationAnalysisGeneral();
  }

  void _addItem() {
    mediationInputs.add(MediationInput(from: "", to: "", through: ""));
    setState(() {});
  }

  void _populateDataFromModel() {
    mediationInputs = [];
    mediationInputs.addAll(predefinedMediationItems);
    setState(() {});

    // _calculate();
  }

  void _calculate() async {
    await Future.wait<void>(mediationInputs.map((MediationInput element) {
      return (() async =>
          await _addMediationAnalysisPerSignificance(from: element.from, to: element.to, through: element.through))();
      // return _addMediationAnalysisPerSignificance(from: element.from, to: element.to, through: element.through);
    }));
  }

  void _addMediationAnalysisGeneral() {
    List<Map<String, String>> toReturn = [];
    SeminrSummary? seminrSummary = widget.seminrSummary;
    BootstrapSummary? bootstrapSummary = widget.bootstrapSummary;

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
    setState(() {
      mediationGeneral = toReturn;
    });
  }

  // Mediation analysis
  Future<SpecificEffectSignificance?> _addMediationAnalysisPerSignificance(
      {required String from, required String to, required String through}) async {
    enableLoading();
    ConfiguredModel? configuredModel = widget.configuredmodel;

    if (widget.accessToken == null || configuredModel == null) {
      disableLoading();
      return null;
    }

    SpecificEffectSignificance? specificEffectSignificance = await PLSRepository().getSpecificEffectSignificance(
      userToken: widget.accessToken!,
      instructions: InstructionMaker.makeInstructions(model: configuredModel),
      filePath: configuredModel.filePath,
      from: from,
      through: through,
      to: to,
    );
    mediationPerSignificance.add(specificEffectSignificance);
    setState(() {});
    disableLoading();

    return specificEffectSignificance;
  }

  List<String> possibleCompositeNames() {
    List<String> normalComposites = (widget.configuredmodel?.composites ?? [])
        .map((Composite e) => e.name ?? "")
        .where((String element) => element.isNotEmpty)
        .toList();
    normalComposites.add("");
    return normalComposites;
  }

  Widget predefinedInvitation() => Card(
      child: Padding(
          padding: ThemeConstant.padding8(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text("Do you want to load predefined Specific effect significances for 'Corporate Reputation Data'?"),
            Row(
              children: [
                TextButton(onPressed: () => _populateDataFromModel(), child: Text("Load Predefined")),
              ],
            )
          ])));

  Widget loadingNotice() => isLoading
      ? Card(
          child: Padding(
              padding: ThemeConstant.padding8(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text("Mediation analysis can take up to more than 2 minutes to complete. Please be patient."),
              ])))
      : Container();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ThemeConstant.padding16(),
      children: [
        Text("Moderation Analysis"),
        SizedBox(height: 24),
        Row(children: [
          Text("Specific effect significances"),
          Spacer(),
          ElevatedButton(onPressed: () => _addItem(), child: Text("+ Add")),
        ]),
        predefinedInvitation(),
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: mediationInputs.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: mediationInputInEditing == index ? Theme.of(context).primaryColor : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("From"),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: mediationInputs[index].from,
                            items: possibleCompositeNames()
                                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                mediationInputs[index].from = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Through"),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: mediationInputs[index].through,
                            items: possibleCompositeNames()
                                .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                mediationInputs[index].through = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("To"),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: mediationInputs[index].to,
                            items: possibleCompositeNames()
                                .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                mediationInputs[index].to = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loadingNotice(),
        Row(children: [
          ElevatedButton(
            onPressed: () => mediationInputs.isNotEmpty ? _calculate() : null,
            child: Text("Calculate"),
          ),
        ]),
        Text("Specific effect significance analysis"),
        ListView.builder(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            itemCount: mediationPerSignificance.length,
            itemBuilder: (context, index) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Padding(
                    padding: ThemeConstant.padding8(),
                    child: ListTile(
                      title: Text(
                        "Specific effect significance",
                        style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                      ),
                      subtitle: Text(
                        mediationPerSignificance[index]?.specificEffectSignificance?.join("\n") ?? "",
                        style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                      ),
                    ),
                  ),
                )),
        Text("Paths and Bootstrapped Paths (for reference)"),
        ListView.builder(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            itemCount: mediationGeneral.length,
            itemBuilder: (context, index) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Padding(
                    padding: ThemeConstant.padding8(),
                    child: ListTile(
                      title: Text(
                        mediationGeneral[index]["name"] ?? "",
                        style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                      ),
                      subtitle: Text(
                        mediationGeneral[index]["value"] ?? "",
                        style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                      ),
                    ),
                  ),
                ))
      ],
    );
  }
}
