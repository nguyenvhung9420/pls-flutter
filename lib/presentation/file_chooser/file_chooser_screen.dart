import 'package:flutter/material.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';

class FileChooserScreen extends StatefulWidget {
  final Function(String) onDoneWithChoosingFile;
  const FileChooserScreen({super.key, required this.onDoneWithChoosingFile});

  @override
  State<FileChooserScreen> createState() => _FileChooserScreenState();
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
      body: Column(
        children: [
          Text("What is the field delimiter in the dataset?"),
          ToggleButtons(
            children: const <Widget>[
              Text('Comma (,)'),
              Text('Semicolon (;)'),
            ],
            isSelected: [_fieldDelimiter == ',', _fieldDelimiter == ';'],
            onPressed: (int index) {
              setState(() {
                _fieldDelimiter = index == 0 ? ',' : ';';
              });
            },
          ),
          ElevatedButton(
            onPressed: _fieldDelimiter != null ? () => _pickFile() : null,
            child: const Text("Upload File"),
          ),
          Text("Columns: ${_data.isNotEmpty ? _data.first.length : 0}, Rows: ${_data.length}"),
          Text("First 10 rows are preview below"),
          Expanded(
            child: _data.isEmpty
                ? const Center(child: Text("No data yet"))
                : SingleChildScrollView(
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
                  ),
          )
          // Expanded(
          //   child: _data.isEmpty
          //       ? const Center(child: Text("No data yet"))
          //       : ListView(
          //           primary: false,
          //           shrinkWrap: true,
          //           children: [
          //             Text('Columns: ${_data.isNotEmpty ? _data.first.length : 0}, Rows: ${_data.length}'),
          //             Text(
          //               "Column headers are ${_data.first.join(', ')}",
          //             )
          //           ],
          //         ),
          // )
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: _data.length,
          //     itemBuilder: (_, index) {
          //       return ListTile(
          //         title: Text(_data[index].join(' - ')),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
