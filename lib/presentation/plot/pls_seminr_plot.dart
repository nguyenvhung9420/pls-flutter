import 'package:flutter/material.dart';
import 'package:pls_flutter/presentation/base_state/base_state.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlsSeminrPlot extends StatefulWidget {
  final String graphVizString;
  final String plotProvider;
  PlsSeminrPlot({super.key, required this.graphVizString, required this.plotProvider});

  @override
  _PlsSeminrPlotState createState() => _PlsSeminrPlotState();
}

class _PlsSeminrPlotState extends BaseState<PlsSeminrPlot> {
  WebViewController? controller;

  @override
  void initState() {
    super.initState();

    String encodeString = Uri.encodeComponent(widget.graphVizString);
    // String url = "https://quickchart.io/graphviz?graph=$encodeString";
    String url = "${widget.plotProvider}$encodeString";

    debugPrint('>>> url: $url');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if (progress < 100) {
              enableLoading();
            } else {
              disableLoading();
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  // void loadWebPage() {
  //   controller?.loadRequest(Uri.parse('https://flutter.dev'));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Example'),
        bottom: defaultLinearProgressBar(context),
      ),
      body: controller == null ? Center(child: CircularProgressIndicator()) : WebViewWidget(controller: controller!),
    );
  }
}
