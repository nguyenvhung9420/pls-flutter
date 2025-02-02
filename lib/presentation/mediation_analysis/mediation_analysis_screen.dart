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
import 'package:pls_flutter/presentation/models/composite.dart';
import 'package:pls_flutter/presentation/models/relationship_path.dart';
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

  String dataNotAvailable =
      "Data not available. Please back to Home and conduct Model Summary and Bootstrap Summary first";

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

  void _calculate({required MediationInput element}) async {
    await _addMediationAnalysisPerSignificance(from: element.from, to: element.to, through: element.through);
  }

  void _addMediationAnalysisGeneral() {
    List<Map<String, String>> toReturn = [];
    SeminrSummary? seminrSummary = widget.seminrSummary;
    BootstrapSummary? bootstrapSummary = widget.bootstrapSummary;

    toReturn.add({
      "name": "Total Effects",
      "value": seminrSummary?.totalEffects?.join("\n") ?? dataNotAvailable,
    });
    toReturn.add({
      "name": "Total Indirect Effects",
      "value": seminrSummary?.totalIndirectEffects?.join("\n") ?? dataNotAvailable,
    });
    toReturn.add({
      "name": "Paths",
      "value": seminrSummary?.paths?.join("\n") ?? dataNotAvailable,
    });
    toReturn.add({
      "name": "Bootstrapped Paths",
      "value": bootstrapSummary?.bootstrappedPaths?.join("\n") ?? dataNotAvailable,
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
    specificEffectSignificance?.forInput = MediationInput(from: from, to: to, through: through);
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

  Widget predefinedInvitation() => Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
      ),
      child: Padding(
          padding: ThemeConstant.padding16(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text("Do you want to load predefined Specific effect significances for 'Corporate Reputation Data'?"),
            Row(
              children: [
                Spacer(),
                TextButton(
                    onPressed: () => _populateDataFromModel(),
                    child: Text("Load Predefined", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            )
          ])));

  bool _isReadyForCalculation({required MediationInput element}) {
    return element.from.isNotEmpty && element.to.isNotEmpty && element.through.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ThemeConstant.padding16(),
      children: [
        Padding(
          padding: ThemeConstant.padding8(horizontal: false, vertical: true),
          child: Text(
            "Mediation Analysis",
            style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 24),
        makeSection([
          Row(children: [
            Text(
              "Specific effect significances".toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                  fontWeight: FontWeight.w600),
            ),
            Spacer(),
            TextButton(onPressed: () => _addItem(), child: Text("+ Add")),
          ]),
          predefinedInvitation(),
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: mediationInputs.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: mediationInputInEditing == index
                          ? Theme.of(context).primaryColor
                          : Colors.black.withOpacity(0.1),
                      width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.2),
                child: Padding(
                  padding: ThemeConstant.padding16(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: _isReadyForCalculation(element: mediationInputs[index])
                                  ? () {
                                      _calculate(element: mediationInputs[index]);
                                    }
                                  : null,
                              child: Text("Calculate", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 24),
                          TextButton(
                              onPressed: () {
                                mediationInputs.removeAt(index);
                                setState(() {});
                              },
                              child: Text("Delete")),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ]),
        ThemeConstant.sizedBox16,
        makeSection([
          Text(
            "Specific effect significance analysis".toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                fontWeight: FontWeight.w600),
          ),
          loadingNotice(),
          mediationPerSignificance.isEmpty
              ? Container(
                  padding: ThemeConstant.padding16(),
                  child: Text(
                    "Please press Calculate on each mediation input to calculate specific effect significance",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: mediationPerSignificance.length,
                  itemBuilder: (context, index) => Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: ThemeConstant.padding8(),
                          child: ListTile(
                            title: Text(
                              mediationPerSignificance[index]?.getForInput() ?? "Specific effect significance",
                              style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                            ),
                            subtitle: Text(
                              mediationPerSignificance[index]?.specificEffectSignificance?.join("\n") ?? "",
                              style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                            ),
                          ),
                        ),
                      )),
        ]),
        ThemeConstant.sizedBox16,
        makeSection([
          Text(
            "Paths and Bootstrapped Paths (for reference)".toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                fontWeight: FontWeight.w600),
          ),
          ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              itemCount: mediationGeneral.length,
              itemBuilder: (context, index) => Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
                        borderRadius: BorderRadius.circular(12)),
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
                          mediationGeneral[index]["value"] ?? dataNotAvailable,
                          style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                        ),
                      ),
                    ),
                  ))
        ])
      ],
    );
  }
}
