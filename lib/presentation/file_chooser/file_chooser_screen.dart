import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pls_flutter/presentation/base_state/pls_textfield.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/prepared_setups/prepared_setups.dart';
import 'package:pls_flutter/utils/theme_constant.dart';

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
      composites = widget.configuredModel!.composites;
      paths = widget.configuredModel!.paths;
      await _processFile(filePath);
    }
  }

  void _populateDataFromModel(ConfiguredModel configuredModel) async {
    if (filePath == null) {
      debugPrint(">>> filePath is null");
      return;
    }
    _fieldDelimiter = configuredModel.delimiter;
    filePath = filePath;
    composites = configuredModel.composites;
    paths = configuredModel.paths;
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

  void _onDoneWithModelSetup() {
    widget.onDoneWithModelSetup(ConfiguredModel(
        composites: composites,
        paths: paths,
        delimiter: _fieldDelimiter!,
        filePath: filePath!,
        usePathWeighting: usePathWeighting));
    Navigator.of(context).pop();
  }

  Widget makeSection(List<Widget> children) {
    return Container(
        padding: ThemeConstant.padding16(),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key, // Assign the key to Scaffold.
        appBar: AppBar(
          elevation: 1,
          title: const Text("Data Import"),
          actions: [
            TextButton.icon(
              onPressed: (filePath ?? "").isEmpty ? null : () => _onDoneWithModelSetup(),
              icon: const Icon(Icons.check),
              label: Text("DONE"),
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
                  TextButton(
                    child: Text("Open Drawer"),
                    onPressed: () {
                      _key.currentState!.openEndDrawer();
                    },
                  ),
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
                  _data.isEmpty
                      ? Container()
                      : makeSection([
                          ExpansionTile(
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
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 76, 64, 64),
                                        border: Border.all(color: Colors.black)),
                                    columns: _buildColumns(), // <--- columns
                                    rows: _buildRows(), // <--- rows
                                  ),
                                ),
                              )
                            ],
                          ),
                        ]),
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
                      Expanded(child: Text("Measurement model")),
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
                          },
                          icon: Icon(Icons.add)),
                    ]),
                    paths.isEmpty
                        ? Padding(
                            padding: ThemeConstant.padding16(),
                            child: Text("Press + button to add a construct", textAlign: TextAlign.center))
                        : ListView.builder(
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
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: compositeIndexInEditing == index
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
                          ),
                  ]),
                  ThemeConstant.sizedBox16,
                  makeSection([
                    Row(children: [
                      Expanded(child: Text("Structural model")),
                      IconButton(
                          onPressed: () {
                            paths.add(RelationshipPath(from: [], to: []));
                            pathIndexInEditing = paths.length - 1;
                            compositeIndexInEditing = null;
                            setState(() {});
                          },
                          icon: Icon(Icons.add)),
                    ]),
                    paths.isEmpty
                        ? Padding(
                            padding: ThemeConstant.padding16(),
                            child: Text("Press + button to add a path (relationship)", textAlign: TextAlign.center))
                        : ListView.builder(
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
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: pathIndexInEditing == index
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
                                        Expanded(
                                          child: Text(_makePathString(index),
                                              style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily)),
                                        ),
                                        Icon(Icons.edit_outlined),
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
            // COMPOSITE EDITING
            Flexible(
              flex: compositeIndexInEditing == null ? 0 : 1,
              child: compositeIndexInEditing == null
                  ? Container()
                  : ListView(
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
                          },
                        ),
                      ],
                    ),
            ),
            // RELATIONSHIP PATHS EDITING
            Flexible(
              flex: pathIndexInEditing == null ? 0 : 1,
              child: pathIndexInEditing == null
                  ? Container()
                  : ListView(
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
              ListTile(
                title: Text("Add Composite"),
              ),
              ListTile(
                title: Text("Add Path"),
              ),
            ],
          ),
        ));
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
