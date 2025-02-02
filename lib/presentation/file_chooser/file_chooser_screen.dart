import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pls_flutter/presentation/base_state/pls_textfield.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/presentation/models/multi_item.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/prepared_setups/prepared_setups.dart';
import 'package:pls_flutter/utils/theme_constant.dart';
import 'package:pls_flutter/presentation/models/composite.dart';
import 'package:pls_flutter/presentation/models/relationship_path.dart';

class FileChooserScreen extends StatefulWidget {
  final Function(ConfiguredModel) onDoneWithModelSetup;
  final ConfiguredModel? configuredModel;
  const FileChooserScreen({super.key, required this.onDoneWithModelSetup, required this.configuredModel});

  @override
  State<FileChooserScreen> createState() => _FileChooserScreenState();
}

class _FileChooserScreenState extends BaseState<FileChooserScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  String? filePath;
  List<List<dynamic>> _data = [];
  bool usePathWeighting = false;
  String? _fieldDelimiter;

  @override
  void initState() {
    super.initState();
    _populateData();
  }

  void _populateData() async {
    if (widget.configuredModel != null) {
      _fieldDelimiter = widget.configuredModel!.delimiter;
      filePath = widget.configuredModel!.filePath;
      composites.clear();
      composites.addAll(widget.configuredModel!.composites);
      paths.clear();
      paths.addAll(widget.configuredModel!.paths);
      await _processFile(filePath);
    }
  }

  void _populateDataFromModel(ConfiguredModel configuredModel) async {
    debugPrint(">>> _populateDataFromModel configuredModel.composites = ${configuredModel.composites.length}");

    if (filePath == null) {
      debugPrint(">>> filePath is null");
      return;
    }
    _fieldDelimiter = configuredModel.delimiter;
    filePath = filePath;
    composites.clear();
    composites.addAll(configuredModel.composites);
    paths.clear();
    paths.addAll(configuredModel.paths);
    usePathWeighting = configuredModel.usePathWeighting;
    setState(() {});
  }

  void _pickFile() async {
    if (_fieldDelimiter == null) return;
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    filePath = result.files.single.path!;
    setState(() {
      filePath = filePath;
    });
    await _processFile(filePath);
  }

  Future<void> _processFile(String? filePath) async {
    final input = File(filePath!).openRead();
    final List<String> fields = await input.transform(utf8.decoder).transform(LineSplitter()).toList();

    List<List<dynamic>> data = fields.map((String element) {
      return element.split(_fieldDelimiter!);
    }).toList();
    setState(() {
      _data = data;
    });
    FilePathRepository().saveFilePath(filePath: filePath);
  }

  List<DataColumn> _buildColumns() {
    if (_data.isEmpty) return [];
    return _data.first.map((dynamic each) {
      return DataColumn(
        label: Expanded(
          child: Text(
            each.toString(),
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }).toList();
  }

  List<DataRow> _buildRows() {
    if (_data.isEmpty) return [];
    List<List<dynamic>> restRows = (_data.take(11).toList()).skip(1).toList();
    return restRows.map((List<dynamic> row) {
      return DataRow(
        cells: row.map((dynamic cell) {
          return DataCell(Text(cell.toString()));
        }).toList(),
      );
    }).toList();
  }

  List<Composite> composites = [];
  List<RelationshipPath> paths = [];
  int? compositeIndexInEditing;
  int? pathIndexInEditing;

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

  Future<bool?> _showSaveDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        String contentText = 'Do you want to save the changes on your dataset and measurement and structural models?';

        if (composites.isEmpty) {
          contentText = 'Your measurement model (including composites) is empty. Do you still want to save?';
        } else if (paths.isEmpty) {
          contentText = 'Your structural model is empty. Do you still want to save?';
        }

        return AlertDialog(
          title: const Text('Save changes before exiting?'),
          content: Text(contentText),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Don\'t Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _onDoneWithModelSetup();

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onDoneWithModelSetup() {
    widget.onDoneWithModelSetup(ConfiguredModel(
        composites: composites,
        paths: paths,
        delimiter: _fieldDelimiter!,
        filePath: filePath!,
        usePathWeighting: usePathWeighting));
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
        key: _key, // Assign the key to Scaffold.
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          title: const Text("Data Import"),
          actions: [
            TextButton(
              onPressed: () {
                if ((filePath ?? "").isEmpty) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  _showSaveDialog(context);
                }
              },
              child: Text((filePath ?? "").isEmpty ? "EXIT" : "DONE",
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            )
          ],
        ),
        body: Row(
          children: [
            Flexible(
              flex: 3,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  makeSection([
                    Text("What is the field delimiter in the dataset?"),
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(value: ',', label: Text('Comma (,)')),
                        ButtonSegment<String>(value: ';', label: Text('Semicolon (;)')),
                      ],
                      selected: <String>{_fieldDelimiter ?? ''},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _fieldDelimiter = newSelection.first;
                        });
                      },
                    ),
                  ]),
                  ThemeConstant.sizedBox16,
                  makeSection([
                    Text("Let's add your CSV file"),
                    ElevatedButton(
                      onPressed: _fieldDelimiter != null ? () => _pickFile() : null,
                      child: const Text("Upload File"),
                    ),
                    _data.isNotEmpty
                        ? Row(
                            children: [
                              Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
                              ThemeConstant.sizedBox8,
                              Text(
                                  "${_data.isNotEmpty ? _data.first.length : 0} columns and ${_data.length} rows retrieved.",
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            ],
                          )
                        : Container(),
                  ]),
                  ThemeConstant.sizedBox16,
                  _data.isEmpty ? Container() : makeSection([firstTenRowsPreview()]),
                  ThemeConstant.sizedBox16,
                  Card(
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: ThemeConstant.padding16(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Do you want to load predefined setups for 'Corporate Reputation Data'?"),
                          Wrap(
                            children: [
                              TextButton(
                                  onPressed: () => _populateDataFromModel(corpDataModel),
                                  child: Text("Load basic setup")),
                              TextButton(
                                  onPressed: () => _populateDataFromModel(corpDataModelExt),
                                  child: Text("Load extended setup")),
                              TextButton(
                                  onPressed: () => _populateDataFromModel(corpDataModelExtModeration),
                                  child: Text("Load extended setup with Moderation Analysis")),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  ThemeConstant.sizedBox16,
                  makeSection([
                    Row(children: [
                      Expanded(child: makeSectionTitle("Measurement model")),
                      IconButton(
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
                            openEndDrawer();
                          },
                          icon: Icon(Icons.add)),
                    ]),
                    composites.isEmpty
                        ? Padding(
                            padding: ThemeConstant.padding16(),
                            child: Text("Press + button to add a construct", textAlign: TextAlign.center))
                        : listComposites(),
                  ]),
                  ThemeConstant.sizedBox16,
                  makeSection([
                    Row(children: [
                      Expanded(child: makeSectionTitle("Structural model")),
                      IconButton(
                          onPressed: () {
                            paths.add(RelationshipPath(from: [], to: []));
                            pathIndexInEditing = paths.length - 1;
                            compositeIndexInEditing = null;
                            setState(() {});
                            openEndDrawer();
                          },
                          icon: Icon(Icons.add)),
                    ]),
                    paths.isEmpty
                        ? Padding(
                            padding: ThemeConstant.padding16(),
                            child: Text("Press + button to add a path (relationship)", textAlign: TextAlign.center))
                        : listPaths(),
                  ]),
                  ThemeConstant.sizedBox16,
                  makeSection([
                    Row(children: [
                      Expanded(child: Text("Use path weighting to estimate PLS model")),
                      Switch(
                        value: usePathWeighting,
                        onChanged: (bool value) {
                          setState(() {
                            usePathWeighting = value;
                          });
                        },
                      ),
                    ]),
                  ])
                ],
              ),
            ),
          ],
        ),
        endDrawerEnableOpenDragGesture: false,
        endDrawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView(
            children: [
              Row(
                children: [
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        itemShouldSaved();
                      },
                      icon: Icon(Icons.close))
                ],
              ),
              // COMPOSITE EDITING
              compositeIndexInEditing == null ? Container() : listCompositesEditing(),
              // RELATIONSHIP PATHS EDITING
              pathIndexInEditing == null ? Container() : listPathsEditing(),
            ],
          ),
        ));
  }

  ListView listPaths() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: paths.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            setState(() {
              pathIndexInEditing = index;
              compositeIndexInEditing = null;
            });
            openEndDrawer();
          },
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: pathIndexInEditing == index ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child:
                        Text(_makePathString(index), style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily)),
                  ),
                  Icon(Icons.edit_outlined),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ListView listComposites() {
    return ListView.builder(
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
                color: compositeIndexInEditing == index ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(makeCompositeCommandString(index),
                        style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily)),
                  ),
                  Icon(Icons.edit_outlined),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ListView listPathsEditing() {
    return ListView(
      primary: false,
      shrinkWrap: true,
      padding: ThemeConstant.padding8(),
      children: [
        Text("From"),
        Builder(builder: (context) {
          int compositeNamesCount = possibleCompositeNames().length;
          return Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(
              compositeNamesCount,
              (int index) {
                String compositeName = possibleCompositeNames()[index];
                return ChoiceChip(
                  label: Text(possibleCompositeNames()[index]),
                  selected: paths[pathIndexInEditing!].from.contains(compositeName),
                  onSelected: (bool selected) {
                    if (selected == false) {
                      paths[pathIndexInEditing!].from.remove(compositeName);
                    } else {
                      paths[pathIndexInEditing!].from.add(compositeName);
                    }
                    setState(() {});
                  },
                );
              },
            ).toList(),
          );
        }),
        Text("To"),
        Builder(builder: (context) {
          int compositeNamesCount = possibleCompositeNames().length;
          return Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(
              compositeNamesCount,
              (int index) {
                String compositeName = possibleCompositeNames()[index];
                return ChoiceChip(
                  label: Text(possibleCompositeNames()[index]),
                  selected: paths[pathIndexInEditing!].to.contains(compositeName),
                  onSelected: (bool selected) {
                    if (selected == false) {
                      paths[pathIndexInEditing!].to.remove(compositeName);
                    } else {
                      paths[pathIndexInEditing!].to.add(compositeName);
                    }
                    setState(() {});
                  },
                );
              },
            ).toList(),
          );
        }),
        ThemeConstant.sizedBox16,
        saveButton(snackBarMessage: "Path saved!"),
      ],
    );
  }

  ListView listCompositesEditing() {
    return ListView(
      primary: false,
      shrinkWrap: true,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Use mode B for weight?"),
            Spacer(),
            Switch(
              value: composites[compositeIndexInEditing!].weight == "mode_B",
              onChanged: (bool value) {
                setState(() => composites[compositeIndexInEditing!].weight = value ? "mode_B" : null);
              },
            ),
          ],
        ),
        ThemeConstant.sizedBox8,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text("Is this an interaction term (for Moderation analysis)?")),
            Switch(
              value: composites[compositeIndexInEditing!].isInteractionTerm,
              onChanged: (bool value) {
                setState(() => composites[compositeIndexInEditing!].isInteractionTerm = value);
              },
            ),
          ],
        ),
        ThemeConstant.sizedBox8,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Is this a multi item?"),
            Spacer(),
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
                  setState(() => composites[compositeIndexInEditing!].multiItem?.from = int.parse(newVal));
                },
              ),
              ThemeConstant.sizedBox8,
              PLSTextField(
                  controller: _toController,
                  labelText: "To",
                  onChanged: (String newVal) {
                    setState(() => composites[compositeIndexInEditing!].multiItem?.to = int.parse(newVal));
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
              showAlertView(
                  title: "Are you sure?",
                  body: 'Do you want to delete this "${composites[compositeIndexInEditing!].name}" construct?',
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        showSnackBar(message: "${composites[compositeIndexInEditing!].name} construct deleted.");
                        setState(() => composites.removeAt(compositeIndexInEditing!));
                        Navigator.of(context).pop();
                        itemShouldSaved();
                      },
                      child: Text("Delete"),
                    ),
                  ]);
            });
          },
        ),
        ThemeConstant.sizedBox16,
        saveButton(snackBarMessage: "${composites[compositeIndexInEditing!].name} saved!"),
      ],
    );
  }

  TextButton saveButton({String snackBarMessage = "Saved!"}) {
    return TextButton.icon(
      label: Text("Save"),
      icon: Icon(Icons.check),
      onPressed: () {
        itemShouldSaved();
        showSnackBar(message: snackBarMessage);
      },
    );
  }

  void itemShouldSaved() {
    setState(() {
      compositeIndexInEditing = null;
      pathIndexInEditing = null;
    });
    closeEndDrawer();
  }

  ExpansionTile firstTenRowsPreview() {
    return ExpansionTile(
      tilePadding: const EdgeInsets.all(0),
      initiallyExpanded: false,
      title: Text("First 10 rows are preview below"),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              decoration:
                  BoxDecoration(color: const Color.fromARGB(255, 76, 64, 64), border: Border.all(color: Colors.black)),
              columns: _buildColumns(), // <--- columns
              rows: _buildRows(), // <--- rows
            ),
          ),
        )
      ],
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

  String _makePathString(int index) {
    return paths[index].makePathString();
  }

  String makeCompositeCommandString(int index) {
    return composites[index].makeCompositeCommandString();
  }
}
