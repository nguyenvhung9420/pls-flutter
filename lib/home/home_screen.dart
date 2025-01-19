import 'package:flutter/material.dart';
import 'package:pls_flutter/home/task_chooser_screen.dart';
import 'package:pls_flutter/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class SampleData {
  String name;
  String description;
  SampleData({required this.name, required this.description});
}

class _MyHomePageState extends State<MyHomePage> {
  final List<SampleData> sampleDataList = [
    SampleData(name: 'Item 1', description: 'Description for Item 1'),
    SampleData(name: 'Item 2', description: 'Description for Item 2'),
    SampleData(name: 'Item 3', description: 'Description for Item 3'),
    SampleData(name: 'Item 4', description: 'Description for Item 4'),
    SampleData(name: 'Item 5', description: 'Description for Item 5'),
  ];

  void _incrementCounter() {
    String currentTime = Utils.getCurrentTimeString();
    sampleDataList.add(SampleData(name: currentTime, description: "Task required"));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskChooserScreen(
          onTaskSelected: (taskSelected) {
            String currentTime = Utils.getCurrentTimeString();
            setState(() {
              sampleDataList
                  .add(SampleData(name: '$currentTime: Item ${sampleDataList.length + 1}', description: taskSelected));
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: sampleDataList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sampleDataList[index].name),
            subtitle: Text(sampleDataList[index].description),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Add more',
        child: const Icon(Icons.add),
      ),
    );
  }
}
