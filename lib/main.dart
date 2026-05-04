import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BokVipApp());
}

class BokVipApp extends StatelessWidget {
  const BokVipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FullScreenPwa(),
    );
  }
}

class FullScreenPwa extends StatefulWidget {
  const FullScreenPwa({super.key});

  @override
  State<FullScreenPwa> createState() => _FullScreenPwaState();
}

class _FullScreenPwaState extends State<FullScreenPwa> {
  late final WebViewController controller;

  static const String appUrl = 'https://willowy-blancmange-3165f7.netlify.app/';

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {},
        ),
      )
      ..loadRequest(Uri.parse(appUrl));
  }

  Future<bool> handleBack() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBack,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: WebViewWidget(controller: controller),
      ),
    );
  }
}
