import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pls_flutter/presentation/models/model_setups.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/prepared_setups/prepared_setups.dart';
import 'package:pls_flutter/utils/theme_constant.dart';

class FileChooserScreen extends StatefulWidget {
  final Function(ConfiguredModel) onDoneWithModelSetup;
  final ConfiguredModel? configuredModel;
  const FileChooserScreen(
      {super.key,
      required this.onDoneWithModelSetup,
      required this.configuredModel});

  @override
  State<FileChooserScreen> createState() => _FileChooserScreenState();
}

class _FileChooserScreenState extends BaseState<FileChooserScreen> {
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

  // void _testPickFile() async {
  //   if (_fieldDelimiter == null) return;
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   if (result == null) return;
  //   filePath = result.files.single.path!;
  //   // setState(() {
  //   //   filePath = filePath;
  //   // });
  //   final input = File(filePath!).openRead();
  //   final List<List<dynamic>> fields = await input
  //       .transform(utf8.decoder)
  //       .transform(CsvToListConverter())
  //       .toList();

  //   debugPrint(">>> fields: $fields");
  // }

  Future<void> _processFile(String? filePath) async {
    final input = File(filePath!).openRead();
    final List<String> fields =
        await input.transform(utf8.decoder).transform(LineSplitter()).toList();

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
    List<String> normalComposites = composites
        .map((Composite e) => e.name ?? "")
        .where((String element) => element.isNotEmpty)
        .toList();
    return normalComposites;
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _singleItemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CSV Data Import"),
        actions: [
          TextButton(
              onPressed: (filePath ?? "").isEmpty
                  ? null
                  : () {
                      widget.onDoneWithModelSetup(ConfiguredModel(
                          composites: composites,
                          paths: paths,
                          delimiter: _fieldDelimiter!,
                          filePath: filePath!,
                          usePathWeighting: usePathWeighting));
                      Navigator.of(context).pop();
                    },
              child: Text("Done"))
        ],
      ),
      body: Row(
        children: [
          Flexible(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("What is the field delimiter in the dataset?"),
                ToggleButtons(
                  isSelected: [_fieldDelimiter == ',', _fieldDelimiter == ';'],
                  onPressed: (int index) {
                    setState(() {
                      _fieldDelimiter = index == 0 ? ',' : ';';
                    });
                  },
                  children: const <Widget>[
                    Text('Comma (,)'),
                    Text('Semicolon (;)'),
                  ],
                ),
                ElevatedButton(
                  onPressed: _fieldDelimiter != null ? () => _pickFile() : null,
                  // onPressed:
                  //     _fieldDelimiter != null ? () => _testPickFile() : null,
                  child: const Text("Upload File"),
                ),
                Text(
                    "Columns: ${_data.isNotEmpty ? _data.first.length : 0}, Rows: ${_data.length}"),
                Expanded(
                  child: _data.isEmpty
                      ? const Center(child: Text("No data yet"))
                      : ExpansionTile(
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
                                      color:
                                          const Color.fromARGB(255, 76, 64, 64),
                                      border: Border.all(color: Colors.black)),
                                  columns: _buildColumns(), // <--- columns
                                  rows: _buildRows(), // <--- rows
                                ),
                              ),
                            )
                          ],
                        ),
                ),
                Card(
                  child: Padding(
                    padding: ThemeConstant.padding8(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Do you want to load predefined setups for 'Corporate Reputation Data'?"),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () =>
                                      _populateDataFromModel(corpDataModel),
                                  child: Text("Load basic setup")),
                              TextButton(
                                  onPressed: () =>
                                      _populateDataFromModel(corpDataModelExt),
                                  child: Text("Load extended setup")),
                              TextButton(
                                  onPressed: () => _populateDataFromModel(
                                      corpDataModelExtModeration),
                                  child: Text(
                                      "Load extended setup with Moderation Analysis")),
                            ],
                          )
                        ]),
                  ),
                ),
                Row(children: [
                  Text("Measurement model"),
                  TextButton(
                      onPressed: () {
                        composites.add(Composite(
                          name: "[No Name]",
                          weight: null,
                          singleItem: null,
                          multiItem:
                              MultiItem(prefix: "construction", from: 1, to: 1),
                          isMulti: true,
                          isInteractionTerm: false,
                          iv: null,
                          moderator: null,
                        ));
                        compositeIndexInEditing = composites.length - 1;
                        pathIndexInEditing = null;
                        setState(() {});
                      },
                      child: Text("Add Construct")),
                ]),
                ListView.builder(
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
                              Builder(builder: (context) {
                                String finalString =
                                    makeCompositeCommandString(index);
                                return Text(finalString);
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
                Row(children: [
                  Text("Structural model"),
                  TextButton(
                      onPressed: () {
                        paths.add(RelationshipPath(from: [], to: []));
                        pathIndexInEditing = paths.length - 1;
                        compositeIndexInEditing = null;
                        setState(() {});
                      },
                      child: Text("Add Relationships (Paths)")),
                ]),
                Row(children: [
                  Text("Use path weighting to estimate PLS model"),
                  Switch(
                    value: usePathWeighting,
                    onChanged: (bool value) {
                      setState(() {
                        usePathWeighting = value;
                      });
                    },
                  ),
                ]),
                ListView.builder(
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
                              Builder(builder: (context) {
                                String finalString = _makePathString(index);
                                return Text(finalString);
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
                      Text(
                          'Construct ${composites[compositeIndexInEditing!].name ?? "Untitled"}'),
                      ThemeConstant.sizedBox16,
                      PLSTextField(
                        controller: _nameController,
                        labelText: "Construct Name",
                        onChanged: (String newVal) {
                          setState(() => composites[compositeIndexInEditing!]
                              .name = newVal.toUpperCase());
                        },
                      ),
                      ThemeConstant.sizedBox8,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Use mode B for weight?"),
                          Switch(
                            value:
                                composites[compositeIndexInEditing!].weight ==
                                    "mode_B",
                            onChanged: (bool value) {
                              setState(() =>
                                  composites[compositeIndexInEditing!].weight =
                                      value ? "mode_B" : null);
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
                          Text(
                              "Is this an interaction term (for Moderation analysis)?"),
                          Switch(
                            value: composites[compositeIndexInEditing!]
                                .isInteractionTerm,
                            onChanged: (bool value) {
                              setState(() =>
                                  composites[compositeIndexInEditing!]
                                      .isInteractionTerm = value);
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
                              setState(() =>
                                  composites[compositeIndexInEditing!].isMulti =
                                      value);
                            },
                          ),
                        ],
                      ),
                      ThemeConstant.sizedBox8,
                      Builder(builder: (ctx) {
                        if (composites[compositeIndexInEditing!]
                            .isInteractionTerm) {
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PLSTextField(
                                  controller: _prefixController,
                                  labelText: "Independent Variable (IV)",
                                  hintText: 'e.g. "CUSA"',
                                  onChanged: (String newVal) {
                                    setState(() {
                                      composites[compositeIndexInEditing!].iv =
                                          newVal;
                                      composites[compositeIndexInEditing!]
                                              .name =
                                          '${composites[compositeIndexInEditing!].iv}*${composites[compositeIndexInEditing!].moderator}';
                                    });
                                    _nameController.text =
                                        composites[compositeIndexInEditing!]
                                                .name ??
                                            "";
                                  },
                                ),
                                ThemeConstant.sizedBox8,
                                PLSTextField(
                                  controller: _fromController,
                                  labelText: "Moderator",
                                  onChanged: (String newVal) {
                                    setState(() {
                                      composites[compositeIndexInEditing!]
                                          .moderator = newVal;
                                      composites[compositeIndexInEditing!]
                                              .name =
                                          '${composites[compositeIndexInEditing!].iv}*${composites[compositeIndexInEditing!].moderator}';

                                      _nameController.text =
                                          composites[compositeIndexInEditing!]
                                                  .name ??
                                              "";
                                    });
                                  },
                                ),
                              ]);
                        }

                        if (composites[compositeIndexInEditing!].isMulti) {
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PLSTextField(
                                  controller: _prefixController,
                                  labelText: "Prefix",
                                  hintText: 'e.g. "cusl_"',
                                  onChanged: (String newVal) {
                                    setState(() =>
                                        composites[compositeIndexInEditing!]
                                            .multiItem
                                            ?.prefix = newVal);
                                  },
                                ),
                                ThemeConstant.sizedBox8,
                                PLSTextField(
                                  controller: _fromController,
                                  labelText: "From",
                                  onChanged: (String newVal) {
                                    setState(() =>
                                        composites[compositeIndexInEditing!]
                                            .multiItem
                                            ?.from = int.parse(newVal));
                                  },
                                ),
                                ThemeConstant.sizedBox8,
                                PLSTextField(
                                    controller: _toController,
                                    labelText: "To",
                                    onChanged: (String newVal) {
                                      setState(() =>
                                          composites[compositeIndexInEditing!]
                                              .multiItem
                                              ?.to = int.parse(newVal));
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
                                setState(() =>
                                    composites[compositeIndexInEditing!]
                                        .singleItem = newVal);
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
                        int compositeNamesCount =
                            possibleCompositeNames().length;
                        return Wrap(
                          spacing: 5.0,
                          children: List<Widget>.generate(
                            compositeNamesCount,
                            (int index) {
                              String compositeName =
                                  possibleCompositeNames()[index];
                              return ChoiceChip(
                                label: Text(possibleCompositeNames()[index]),
                                selected: paths[pathIndexInEditing!]
                                    .from
                                    .contains(compositeName),
                                onSelected: (bool selected) {
                                  if (selected == false) {
                                    paths[pathIndexInEditing!]
                                        .from
                                        .remove(compositeName);
                                  } else {
                                    paths[pathIndexInEditing!]
                                        .from
                                        .add(compositeName);
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
                        int compositeNamesCount =
                            possibleCompositeNames().length;
                        return Wrap(
                          spacing: 5.0,
                          children: List<Widget>.generate(
                            compositeNamesCount,
                            (int index) {
                              String compositeName =
                                  possibleCompositeNames()[index];
                              return ChoiceChip(
                                label: Text(possibleCompositeNames()[index]),
                                selected: paths[pathIndexInEditing!]
                                    .to
                                    .contains(compositeName),
                                onSelected: (bool selected) {
                                  if (selected == false) {
                                    paths[pathIndexInEditing!]
                                        .to
                                        .remove(compositeName);
                                  } else {
                                    paths[pathIndexInEditing!]
                                        .to
                                        .add(compositeName);
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

TextField PLSTextField({
  required TextEditingController controller,
  String labelText = "label",
  String? hintText = "hint",
  required Function(String) onChanged,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onChanged: (String newVal) {
      onChanged(newVal);
    },
  );
}
