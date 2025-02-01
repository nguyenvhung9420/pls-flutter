import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pls_flutter/utils/theme_constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'loading_indicator.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  StreamController<bool> showLoadingHudStream = StreamController.broadcast();
  double defaultPadding = 16.0;

  Widget loadingNotice() => isLoading
      ? Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
          ),
          child: Padding(
              padding: ThemeConstant.padding16(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text("Calculation can take up to 3 minutes to complete due to its complexity. Please be patient."),
                ThemeConstant.sizedBox8,
                isLoading
                    ? Container(
                        clipBehavior: Clip.antiAlias,
                        height: 8,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                        child: LinearProgressIndicator())
                    : Container()
              ])))
      : Container();

  Widget makeBottomSheetTitle(String title) {
    return Padding(
      padding: ThemeConstant.padding8(horizontal: false, vertical: true),
      child: Text(
        title,
        style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget makeSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
          color: Theme.of(context).colorScheme.primaryContainer,
          fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
          fontWeight: FontWeight.w600),
    );
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

  bool get isLoading {
    return _isLoading;
  }

  void setIsLoading({required bool isLoading}) {
    setState(() => _isLoading = isLoading);
  }

  void enableLoading() {
    setState(() => _isLoading = true);
  }

  void disableLoading() {
    setState(() => _isLoading = false);
  }

  void materialPush(StatefulWidget page, {bool andRemoveUntil = false}) {
    if (andRemoveUntil) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => page), (route) => false);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void showAlertView({required String title, required String body, List<Widget> actions = const []}) => showDialog(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(title: Text(title), content: Text(body), actions: actions),
      );

  PreferredSize? defaultLinearProgressBar(BuildContext context) {
    return _isLoading
        ? PreferredSize(
            preferredSize: Size.fromHeight(8.0),
            child: LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
          )
        : null;
  }

  void showError(dynamic e) {
    showAlertView(
        title: "Error",
        body: "Unexpected error: \"${e.toString()}\"",
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))]);
  }

  void showSnackBar({required dynamic message, IconData? iconData}) {
    SnackBar snackBar = SnackBar(showCloseIcon: true, content: Text(message.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget alternativeAppbarTitle({required String title}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemeConstant.sizedBox8,
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ThemeConstant.sizedBox16,
        ThemeConstant.sizedBox16,
      ],
    );
  }

  void showBaseBottomSheet({
    required Widget child,
    required BuildContext context,
    double proportionWithSreenHeight = 0.75,
    Color? backgroundColor,
  }) {
    showMaterialModalBottomSheet<void>(
      enableDrag: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * proportionWithSreenHeight,
          color: backgroundColor,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              child,
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
              isLoading ? LinearProgressIndicator() : Container(),
            ],
          ),
        );
      },
    );
  }

  void showLoadingIndicatorHud([String? text]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            backgroundColor: Colors.black87,
            content: LoadingIndicator(text: text ?? ""),
          ),
        );
      },
    );
  }

  void hideLoadingIndicatorHud() {
    Navigator.of(context).pop();
  }
}
