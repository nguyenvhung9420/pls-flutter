import 'package:flutter/material.dart';
import 'package:pls_flutter/data/models/boostrap_summary.dart';
import 'package:pls_flutter/data/models/seminr_summary.dart';
import 'package:pls_flutter/presentation/models/pls_task_view.dart';
import 'package:pls_flutter/repositories/authentication/auth_repository.dart';
import 'package:pls_flutter/repositories/authentication/token_repository.dart';
import 'package:pls_flutter/repositories/pls_gcloud_repository/pls_gcloud_repository.dart';

class FormativeConvergentValidityScreen extends StatefulWidget {
  const FormativeConvergentValidityScreen({super.key});

  @override
  State<FormativeConvergentValidityScreen> createState() =>
      _FormativeConvergentValidityScreenState();
}

class _FormativeConvergentValidityScreenState
    extends State<FormativeConvergentValidityScreen> {
  String? accessToken;
  PlsTask? selectedTask;
  BootstrapSummary? bootstrapSummary;
  List<SeminrSummary?> seminrSummaries = [];

  List<List<String>> listOfPaths = [];

  @override
  void initState() {
    super.initState();

    _login();
  }

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

  Future<List<Map<String, String>>> _addSummaryPaths(
      {required String constructName}) async {
    if (accessToken == null) return [];
    SeminrSummary? summary = await PLSRepository().getSummaryPaths(
      userToken: accessToken!,
      instructions: "",
      filePath: '',
    );

    setState(() {
      seminrSummaries = [...seminrSummaries, summary];
      listOfPaths = [...listOfPaths, summary?.paths ?? []];
    });

    return summary?.getSummaryList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
