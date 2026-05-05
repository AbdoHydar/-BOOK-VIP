import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xffd50000),
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
      home: SplashThenFastWeb(),
    );
  }
}

class SplashThenFastWeb extends StatefulWidget {
  const SplashThenFastWeb({super.key});

  @override
  State<SplashThenFastWeb> createState() => _SplashThenFastWebState();
}

class _SplashThenFastWebState extends State<SplashThenFastWeb> {
  late final WebViewController controller;
  bool showFlutterSplash = true;

  // لا نحذف splash من الموقع، نفتح الرابط الأصلي
  static const String appUrl = 'https://sweet-tulumba-bde789.netlify.app/';

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) async {
            // تحسينات خفيفة بعد تحميل الصفحة
            await controller.runJavaScript('''
              try {
                document.body.style.webkitTapHighlightColor = 'transparent';
                document.documentElement.style.scrollBehavior = 'auto';

                var videos = document.querySelectorAll('video');
                videos.forEach(function(v){
                  v.setAttribute('playsinline', 'true');
                  v.muted = true;
                });

                var imgs = document.querySelectorAll('img');
                imgs.forEach(function(img){
                  img.loading = 'eager';
                  img.decoding = 'async';
                });
              } catch(e) {}
            ''');

            // نعرض Splash Flutter فقط أثناء التجهيز ثم نكشف الموقع
            Timer(const Duration(milliseconds: 700), () {
              if (mounted) {
                setState(() => showFlutterSplash = false);
              }
            });
          },
          onWebResourceError: (_) {},
        ),
      )
      ..loadRequest(Uri.parse(appUrl));

    // احتياط: لا يبقى Splash Flutter أكثر من 3 ثواني
    Timer(const Duration(seconds: 3), () {
      if (mounted && showFlutterSplash) {
        setState(() => showFlutterSplash = false);
      }
    });
  }

  Future<bool> handleBack() async {
    if (!showFlutterSplash && await controller.canGoBack()) {
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
        backgroundColor: const Color(0xffd50000),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (showFlutterSplash) const FlutterSplash(),
          ],
        ),
      ),
    );
  }
}

class FlutterSplash extends StatelessWidget {
  const FlutterSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffd50000),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: const Text(
        'bankak',
        style: TextStyle(
          color: Colors.white,
          fontSize: 46,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
