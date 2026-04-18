import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapsWebViewPage extends StatefulWidget {
  final double lat;
  final double lng;
  final String name;

  const MapsWebViewPage({
    super.key,
    required this.lat,
    required this.lng,
    required this.name,
  });

  @override
  State<MapsWebViewPage> createState() => _MapsWebViewPageState();
}

class _MapsWebViewPageState extends State<MapsWebViewPage> {
  static const primaryColor = Color(0xFF0056D2);

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (url.startsWith('intent://')) {
              return NavigationDecision.prevent;
            }

            if (url.contains('google.com')) {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.prevent;
          },
          onWebResourceError: (WebResourceError error) {
          },
        ),
      )
      ..loadRequest(Uri.parse(_getMapUrl()));
  }

  String _getMapUrl() {
    return "https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.lng}&zoom=15";
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
        title: Text(
          widget.name,
          style: textTheme.headlineSmall?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          )
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}