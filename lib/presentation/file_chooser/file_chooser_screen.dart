import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/utils/theme_constant.dart';

class FileChooserScreen extends StatefulWidget {
  final Function(String) onDoneWithChoosingFile;
  const FileChooserScreen({super.key, required this.onDoneWithChoosingFile});

  @override
  State<FileChooserScreen> createState() => _FileChooserScreenState();
}

class MultiItem {
  String prefix;
  int from;
  int to;
  MultiItem({required this.prefix, required this.from, required this.to});
}

class Composite {
  // # pls_model:
  // # - constructs -> composites:
  // #     - name
  // #     - multi_items( prefix, from, to )
  // #     - single_item( name )
  // # - relationships:
  // #     - [ paths( from [ ] , to [ ] ) ]
  // # - inner_weights
  // # - missing
  // # - missing_value

  String? name;
  String? weight;
  String? singleItem;
  MultiItem? multiItem;
  bool isMulti;
  Composite(
      {required this.name,
      required this.weight,
      required this.singleItem,
      required this.multiItem,
      required this.isMulti});
}

class _FileChooserScreenState extends BaseState<FileChooserScreen> {
  String? filePath;
  List<List<dynamic>> _data = [];

  String? _fieldDelimiter;

  void _pickFile() async {
    if (_fieldDelimiter == null) return;
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    filePath = result.files.single.path!;
    final input = File(filePath!).openRead();
    final List<String> fields = await input.transform(utf8.decoder).transform(LineSplitter()).toList();

    List<List<dynamic>> data = fields.map((String element) {
      return element.split(_fieldDelimiter!);
    }).toList();
    setState(() {
      _data = data;
    });

    FilePathRepository().saveFilePath(filePath: filePath!);
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
  int? compositeIndexInEditing;

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
              onPressed: (filePath ?? "").isEmpty ? null : () => widget.onDoneWithChoosingFile(filePath!),
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
                  child: const Text("Upload File"),
                ),
                Text("Columns: ${_data.isNotEmpty ? _data.first.length : 0}, Rows: ${_data.length}"),
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
                                    color: Colors.grey.shade100,
                                    border: Border.all(color: Colors.black),
                                  ),
                                  columns: _buildColumns(), // <--- columns
                                  rows: _buildRows(), // <--- rows
                                ),
                              ),
                            )
                          ],
                        ),
                ),
                Row(children: [
                  Text("Construct constructions"),
                  TextButton(
                      onPressed: () {
                        composites.add(Composite(
                            name: "construction",
                            weight: "1",
                            singleItem: null,
                            multiItem: MultiItem(prefix: "construction", from: 1, to: 1),
                            isMulti: true));
                        setState(() {});
                      },
                      child: Text("Add Construct")),
                ]),
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: composites.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
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
                            // composite("COMP", multi_items("comp_", 1:3)),
                            // composite("CUSA", single_item("cusa")),
                            Builder(builder: (context) {
                              String finalString = makeCompositeCommandString(index);
                              return Text(finalString);
                            }),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  compositeIndexInEditing = index;
                                });
                                _nameController.text = composites[index].name ?? "";
                                if (composites[index].isMulti) {
                                  _prefixController.text = composites[index].multiItem?.prefix ?? "";
                                  _fromController.text = composites[index].multiItem?.from.toString() ?? "";
                                  _toController.text = composites[index].multiItem?.to.toString() ?? "";
                                } else {
                                  _singleItemController.text = composites[index].singleItem ?? "";
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Flexible(
              flex: 1,
              child: compositeIndexInEditing == null
                  ? Text("Select a composite to start editing")
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
                        Spacer(),
                        ThemeConstant.sizedBox8,
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              composites.removeAt(compositeIndexInEditing!);
                            });
                          },
                        ),
                      ],
                    ))
        ],
      ),
    );
  }

  String makeCompositeCommandString(int index) {
    String? compositeName = composites[index].name;
    String? itemPrefix = composites[index].multiItem?.prefix;
    String? singleItemName = composites[index].singleItem;
    String range = "${composites[index].multiItem?.from}:${composites[index].multiItem?.to}";
    String itemString = "";
    if (composites[index].isMulti) {
      itemString = 'multi_items("$itemPrefix", $range)';
    } else {
      itemString = 'single_item("$singleItemName")';
    }
    String finalString = 'composite("$compositeName", $itemString)';
    return finalString;
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
