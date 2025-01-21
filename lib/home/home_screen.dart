import 'package:flutter/material.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/home/task_chooser_screen.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';
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
  String? accessToken;

  final List<SampleData> sampleDataList = [
    SampleData(name: 'Item 1', description: 'Description for Item 1'),
    SampleData(name: 'Item 2', description: 'Description for Item 2'),
    SampleData(name: 'Item 3', description: 'Description for Item 3'),
    SampleData(name: 'Item 4', description: 'Description for Item 4'),
    SampleData(name: 'Item 5', description: 'Description for Item 5'),
  ];

  void _login() async {
    accessToken = await AuthTokenRepository().getCurrentAuthToken();

    if (accessToken?.isEmpty == false) {
      setState(() => accessToken = accessToken);
      return;
    }

    accessToken = await AuthRepository().login(
        loginBody: {"username": "hungnguyen_pls_sem", "password": "secret"});

    if (accessToken != null) {
      await AuthTokenRepository().saveAuthToken(token: accessToken!);
      setState(() => accessToken = accessToken);
    }
  }

  void _addSummaryPaths() async {
    if (accessToken == null) return;
    SeminrSummary? summary =
        await PLSRepository().getSummaryPaths(userToken: accessToken!);
    List<String> summaryPaths = summary?.paths ?? [];
    String theWholeString = summaryPaths.join("\n");
    setState(() {
      sampleDataList
          .add(SampleData(name: theWholeString, description: "Summary Path"));
    });
  }

  void _incrementCounter() {
    String currentTime = Utils.getCurrentTimeString();
    sampleDataList
        .add(SampleData(name: currentTime, description: "Task required"));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskChooserScreen(
          onTaskSelected: (taskSelected) {
            _addSummaryPaths();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _login();
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
