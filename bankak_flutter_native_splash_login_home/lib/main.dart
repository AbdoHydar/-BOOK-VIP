import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF7A0000),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const BankakApp());
}

const Color bankRedTop = Color(0xFFEF1017);
const Color bankRedBottom = Color(0xFFBC0D12);

class BankakApp extends StatelessWidget {
  const BankakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bankak',
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Tahoma',
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  VideoPlayerController? _controller;
  bool _fallback = false;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final controller = VideoPlayerController.asset('assets/splash.mp4');
      _controller = controller;
      await controller.initialize();
      await controller.setVolume(0);
      await controller.play();
      controller.addListener(() {
        if (controller.value.isInitialized &&
            controller.value.position >= controller.value.duration) {
          _goNext();
        }
      });
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _fallback = true);
    }

    Timer(const Duration(seconds: 5), _goNext);
  }

  void _goNext() {
    if (_moved || !mounted) return;
    _moved = true;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: const Color(0xFF7A0000),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null && c.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          if (_fallback || c == null || !c.value.isInitialized)
            Container(
              color: const Color(0xFF7A0000),
              alignment: Alignment.center,
              child: const Text(
                'تحميل ...',
                style: TextStyle(
                  color: Color(0xB8FFFFFF),
                  fontSize: 44,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController identifier = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;
  String loadingText = 'جاري تسجيل الدخول ...';
  String toast = '';

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    super.dispose();
  }

  void showToast(String message) {
    setState(() => toast = message);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && toast == message) setState(() => toast = '');
    });
  }

  Future<void> doLogin() async {
    final id = identifier.text.trim();
    final pass = password.text.trim();
    if (id.isEmpty) {
      showToast('يرجى إدخال رقم الحساب');
      return;
    }
    if (pass.isEmpty) {
      showToast('يرجى إدخال كلمة المرور');
      return;
    }

    setState(() {
      loading = true;
      loadingText = 'جاري تسجيل الدخول ...';
    });
    await Future.delayed(const Duration(milliseconds: 900));

    if ((id == '3014021' || id == '2773377') && pass == '1234') {
      setState(() => loadingText = 'تحميل ...');
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => HomePage(userName: id == '2773377' ? 'محمد عبدالله' : 'أحمد محمد'),
        ),
      );
    } else {
      setState(() => loading = false);
      password.clear();
      showToast('بيانات الدخول غير صحيحة');
    }
  }

  void focusField(FocusNode node) => node.requestFocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: LayoutBuilder(
            builder: (context, outer) {
              final width = outer.maxWidth;
              final minHeight = MediaQuery.of(context).size.height;
              final designHeight = width * 1108 / 540;
              final height = designHeight < minHeight ? minHeight : designHeight;

              return SizedBox(
                width: width,
                height: minHeight,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/img/login.png',
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        _LoginTextField(
                          controller: identifier,
                          left: width * 0.48,
                          top: height * 0.3090,
                          width: width * 0.37,
                          height: height * 0.0345,
                          keyboardType: TextInputType.number,
                        ),
                        _LoginTextField(
                          controller: password,
                          left: width * 0.39,
                          top: height * 0.3910,
                          width: width * 0.47,
                          height: height * 0.0345,
                          obscureText: true,
                        ),
                        _TapArea(left: .078, top: .292, width: .844, height: .069, onTap: () {}),
                        _TapArea(left: .078, top: .374, width: .844, height: .069, onTap: () {}),
                        _TapArea(left: .078, top: .470, width: .844, height: .066, onTap: doLogin),
                        _TapArea(left: .078, top: .572, width: .32, height: .042, onTap: () => showToast('حساب جديد')),
                        _TapArea(left: .48, top: .572, width: .40, height: .042, onTap: () => showToast('المساعدة')),
                        _TapArea(left: .078, top: .632, width: .34, height: .044, onTap: () => showToast('مشاركة')),
                        _TapArea(left: .22, top: null, bottom: .057, width: .14, height: .09, onTap: () => showToast('بنك الخرطوم')),
                        _TapArea(left: .38, top: null, bottom: .057, width: .14, height: .09, onTap: () => showToast('مواقعنا')),
                        _TapArea(left: .54, top: null, bottom: .057, width: .14, height: .09, onTap: () => showToast('المساعدة')),
                        _TapArea(left: .70, top: null, bottom: .057, width: .14, height: .09, onTap: () => showToast('فيسبوك')),
                        if (toast.isNotEmpty)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 28,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                decoration: BoxDecoration(
                                  color: const Color(0xEF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(toast, style: const TextStyle(color: Colors.white, fontSize: 14)),
                              ),
                            ),
                          ),
                        if (loading)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0x9E000000),
                              alignment: Alignment.center,
                              child: Text(
                                loadingText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xF5FFFFFF),
                                  fontSize: 25,
                                  height: 1.35,
                                  fontWeight: FontWeight.w400,
                                  shadows: [Shadow(color: Color(0xB3000000), blurRadius: 3, offset: Offset(0, 1))],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final double left;
  final double top;
  final double width;
  final double height;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _LoginTextField({
    required this.controller,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: const Color(0xFF5A5A5A),
          fontSize: 22,
          height: 1,
          letterSpacing: obscureText ? 1 : 0,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _TapArea extends StatelessWidget {
  final double left;
  final double? top;
  final double? bottom;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _TapArea({
    required this.left,
    required this.top,
    this.bottom,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width.clamp(0, 540) * left,
      top: top == null ? null : MediaQuery.of(context).size.height * top!,
      bottom: bottom == null ? null : MediaQuery.of(context).size.height * bottom!,
      width: MediaQuery.of(context).size.width.clamp(0, 540) * width,
      height: MediaQuery.of(context).size.height * height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final items = <_HomeItem>[
      _HomeItem('تحويلات', 'assets/img/grid_3.png'),
      _HomeItem('دفع فواتير', 'assets/img/grid_2.png'),
      _HomeItem('تفاصيل الحساب', 'assets/img/grid_1.png'),
      _HomeItem('طلب الودائع الاستثمارية', 'assets/img/grid_6.png'),
      _HomeItem('بنكك PAY', 'assets/img/grid_5.png'),
      _HomeItem('سحب بدون بطاقة', 'assets/img/grid_4.png'),
      _HomeItem('إدارة البطاقات', 'assets/img/grid_9.png'),
      _HomeItem('المعاملات السابقة', 'assets/img/grid_8.png'),
      _HomeItem('إدارة المستفيدين', 'assets/img/grid_7.png'),
      _HomeItem('الضبط', 'assets/img/grid_12.png'),
      _HomeItem('أمر دفع دائم', 'assets/img/grid_11.png'),
      _HomeItem('طلبات', 'assets/img/grid_10.png'),
      _HomeItem('', ''),
      _HomeItem('خدمات العملات الأجنبية', 'assets/img/grid_14.png'),
      _HomeItem('التجارة الإلكترونية', 'assets/img/grid_13.png'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: 56 + MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 12, right: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bankRedTop, bankRedBottom],
                ),
                boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset('assets/img/notification_icon.png', width: 26, height: 26, fit: BoxFit.contain),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Image.asset('assets/img/scanpayheader.png', height: 60, fit: BoxFit.contain),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const LoginPage())),
                        child: Image.asset('assets/img/logout_icon.png', width: 26, height: 26, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF0F0F0),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'نهارك سعيد، ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 15,
                      childAspectRatio: .92,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item.title.isEmpty) return const SizedBox.shrink();
                      return _HomeTile(item: item);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final String asset;
  _HomeItem(this.title, this.asset);
}

class _HomeTile extends StatelessWidget {
  final _HomeItem item;
  const _HomeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(item.asset, width: 72, height: 72, fit: BoxFit.contain),
          const SizedBox(height: 5),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
