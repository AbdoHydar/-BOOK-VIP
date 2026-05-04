import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
  ));
  runApp(const BokVipApp());
}

const red1 = Color(0xffef1017);
const red2 = Color(0xffb90d13);
const darkText = Color(0xff333333);
const lightBorder = Color(0xffe4e4e4);

class Account {
  String account;
  String password;
  String name;
  String iban;
  double balance;
  bool frozen;
  Account({required this.account, required this.password, required this.name, required this.iban, required this.balance, this.frozen = false});
}

class Txn {
  final String id;
  final String from;
  final String to;
  final String toName;
  final String mobile;
  final String comment;
  final double amount;
  final DateTime time;
  Txn({required this.id, required this.from, required this.to, required this.toName, required this.mobile, required this.comment, required this.amount, required this.time});
}

final Map<String, Account> accounts = {
  '3014021': Account(account: '3014021', password: '1234', name: 'أحمد محمد', iban: 'SD2137240000003014021', balance: 1000000.00),
  '2773377': Account(account: '2773377', password: '1234', name: 'محمد عبدالله', iban: 'SD2137240000002773377', balance: 500000.00),
};
final List<Txn> txns = [];
Account? current;

class BokVipApp extends StatelessWidget {
  const BokVipApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BOK VIP',
      theme: ThemeData(fontFamily: 'Arial', useMaterial3: false, primaryColor: red2),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget { const SplashPage({super.key}); @override State<SplashPage> createState() => _SplashPageState(); }
class _SplashPageState extends State<SplashPage> {
  VideoPlayerController? c;
  @override void initState() { super.initState(); _start(); }
  Future<void> _start() async {
    try {
      c = VideoPlayerController.asset('assets/splash.mp4');
      await c!.initialize();
      c!.play();
    } catch (_) {}
    Timer(const Duration(seconds: 3), () { if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())); });
  }
  @override void dispose() { c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: red2,
      body: Center(
        child: c != null && c!.value.isInitialized
            ? AspectRatio(aspectRatio: c!.value.aspectRatio, child: VideoPlayer(c!))
            : Column(mainAxisSize: MainAxisSize.min, children: [Image.asset('assets/img/bankak_logo_big.png', width: 120, errorBuilder: (_,__,___)=>const Icon(Icons.account_balance, color: Colors.white, size: 100)), const SizedBox(height: 20), const Text('BOK VIP', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final acc = TextEditingController(); final pass = TextEditingController(); String msg = '';
  bool loading = false;
  void login() async {
    setState(() { loading = true; msg = '... جاري تسجيل الدخول'; });
    await Future.delayed(const Duration(milliseconds: 900));
    final a = accounts[acc.text.trim()];
    if (a != null && a.password == pass.text.trim() && !a.frozen) {
      current = a;
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else { setState(() { loading = false; msg = 'بيانات الدخول غير صحيحة'; }); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Stack(children: [
      const LoginHeader(),
      Positioned.fill(top: MediaQuery.of(context).size.height * .37, child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 22), child: Column(children: [
        FieldBox(controller: acc, hint: 'أدخل رقم الحساب (رقم المعرف أو رقم الموبايل)', icon: Icons.person_outline, keyboard: TextInputType.number),
        const SizedBox(height: 27),
        FieldBox(controller: pass, hint: 'أدخل كلمة المرور', icon: Icons.lock_outline, obscure: true),
        const SizedBox(height: 36),
        GestureDetector(onTap: loading ? null : login, child: Container(height: 70, decoration: BoxDecoration(gradient: const LinearGradient(colors: [red1, red2]), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))]), child: Center(child: Text(loading ? '... تحميل' : 'تسجيل الدخول', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))))),
        const SizedBox(height: 18), Text(msg, style: const TextStyle(color: red2, fontSize: 16, fontWeight: FontWeight.w600)),
        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage())), child: const Text('دخول الأدمن', style: TextStyle(color: Colors.grey))),
      ])))
    ]));
  }
}

class LoginHeader extends StatelessWidget { const LoginHeader({super.key}); @override Widget build(BuildContext context) { return ClipPath(clipper: BottomWave(), child: Container(height: MediaQuery.of(context).size.height * .40, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [red1, red2])), child: SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), child: Row(children: const [Text('اتصل بنا', style: TextStyle(color: Colors.white, fontSize: 15)), Icon(Icons.phone, color: Colors.white, size: 18), Spacer(), Text('العربية⌄', style: TextStyle(color: Colors.white, fontSize: 15))])), const Spacer(), Image.asset('assets/img/bankak_logo_big.png', width: 88, errorBuilder: (_,__,___)=>const Icon(Icons.account_balance, color: Colors.white, size: 70)), const SizedBox(height: 8), const Text('BOK VIP', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)), const Spacer(flex: 2)])))); }}

class BottomWave extends CustomClipper<Path> { @override Path getClip(Size s) { final p = Path(); p.lineTo(0, s.height - 35); p.quadraticBezierTo(s.width/2, s.height + 5, s.width, s.height - 35); p.lineTo(s.width, 0); p.close(); return p; } @override bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false; }

class FieldBox extends StatelessWidget { final TextEditingController controller; final String hint; final IconData icon; final bool obscure; final TextInputType? keyboard; const FieldBox({super.key, required this.controller, required this.hint, required this.icon, this.obscure=false, this.keyboard}); @override Widget build(BuildContext context) { return Container(height: 70, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: lightBorder, width: 1.3), borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 7)]), child: TextField(controller: controller, obscureText: obscure, keyboardType: keyboard, textAlign: TextAlign.right, decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.grey), hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 14), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10)))); }}

class HomePage extends StatelessWidget { const HomePage({super.key}); @override Widget build(BuildContext context) { final a = current ?? accounts.values.first; return Scaffold(backgroundColor: Colors.white, body: Column(children: [HomeHeader(name: a.name), Expanded(child: GridView.count(padding: const EdgeInsets.fromLTRB(14, 18, 14, 10), crossAxisCount: 2, childAspectRatio: 2.35, mainAxisSpacing: 10, crossAxisSpacing: 10, children: menuItems.map((m) => MenuTile(item: m)).toList())), const BottomNav() ])); }}

class HomeHeader extends StatelessWidget { final String name; const HomeHeader({super.key, required this.name}); @override Widget build(BuildContext context) { return ClipPath(clipper: BottomWave(), child: Container(height: 210, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [red1, red2])), child: SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: const [Icon(Icons.menu, color: Colors.white, size: 30), Spacer(), Text('BOK VIP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Spacer(), Icon(Icons.notifications_none, color: Colors.white)])), const SizedBox(height: 20), Row(children: [const SizedBox(width: 28), CircleAvatar(radius: 34, backgroundColor: Colors.white, child: Icon(Icons.person, color: red2, size: 42)), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('نهارك سعيد', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))])])])))); }}

class MenuItem { final String title; final String asset; final Widget Function() page; MenuItem(this.title, this.asset, this.page); }
final menuItems = <MenuItem>[
  MenuItem('تحويلات','assets/img/grid_1.png',()=>const TransferPage()), MenuItem('دفع فواتير','assets/img/grid_2.png',()=>const ComingSoonPage(title:'دفع فواتير')),
  MenuItem('تفاصيل الحساب','assets/img/grid_3.png',()=>const AccountPage()), MenuItem('طلب الودائع الأستثمارية','assets/img/grid_4.png',()=>const ComingSoonPage(title:'طلب الودائع الأستثمارية')),
  MenuItem('بنككPAY','assets/img/grid_5.png',()=>const ComingSoonPage(title:'بنككPAY')), MenuItem('سحب بدون بطاقة','assets/img/grid_6.png',()=>const ComingSoonPage(title:'سحب بدون بطاقة')),
  MenuItem('إدارة البطاقات','assets/img/grid_7.png',()=>const ComingSoonPage(title:'إدارة البطاقات')), MenuItem('المعاملات السابقة','assets/img/grid_8.png',()=>const TransactionsPage()),
  MenuItem('إدارةالمستفيدين','assets/img/grid_9.png',()=>const ComingSoonPage(title:'إدارةالمستفيدين')), MenuItem('الضبط','assets/img/grid_10.png',()=>const ComingSoonPage(title:'الضبط')),
  MenuItem('امر دفع دائم','assets/img/grid_11.png',()=>const ComingSoonPage(title:'امر دفع دائم')), MenuItem('طلبات','assets/img/grid_12.png',()=>const ComingSoonPage(title:'طلبات')),
  MenuItem('خدمات العملات الاجنبية','assets/img/grid_13.png',()=>const ComingSoonPage(title:'خدمات العملات الاجنبية')), MenuItem('التجارة الإلكترونية','assets/img/grid_14.png',()=>const ComingSoonPage(title:'التجارة الإلكترونية')),
];
class MenuTile extends StatelessWidget { final MenuItem item; const MenuTile({super.key, required this.item}); @override Widget build(BuildContext context) { return InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>item.page())), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffeeeeee)), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 7, offset: Offset(0,2))]), padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(child: Text(item.title, textAlign: TextAlign.right, style: const TextStyle(color: darkText, fontSize: 15, fontWeight: FontWeight.w500))), const SizedBox(width: 10), Image.asset(item.asset, width: 29, height: 29, errorBuilder: (_,__,___)=>const Icon(Icons.widgets, color: red2))]))); }}
class BottomNav extends StatelessWidget { const BottomNav({super.key}); @override Widget build(BuildContext context) { const labels=['الرئيسية','الحسابات','المدفوعات','البطاقات','المزيد']; const icons=[Icons.home,Icons.account_balance_wallet,Icons.payments,Icons.credit_card,Icons.more_horiz]; return Container(height: 74, decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: lightBorder))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(5, (i)=>Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(icons[i], color: i==0?red2:Colors.grey), Text(labels[i], style: TextStyle(fontSize: 12, color: i==0?red2:Colors.grey, fontWeight: i==0?FontWeight.bold:FontWeight.normal))]))); }}

class TopBar extends StatelessWidget { final String title; const TopBar(this.title,{super.key}); @override Widget build(BuildContext context) { return Container(height: 64, decoration: const BoxDecoration(gradient: LinearGradient(colors:[red1, red2])), child: SafeArea(bottom:false, child: Row(children:[IconButton(onPressed:()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)), Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold))), const SizedBox(width:48)]))); }}
class AccountPage extends StatelessWidget { const AccountPage({super.key}); @override Widget build(BuildContext context) { final a=current??accounts.values.first; return Scaffold(backgroundColor: const Color(0xfff5f5f5), body: Column(children:[const TopBar('تفاصيل الحساب'), Padding(padding: const EdgeInsets.all(16), child: CardBox(children:[InfoRow('إسم صاحب الحساب',a.name), InfoRow('رقم الحساب',a.account), InfoRow('IBAN',a.iban), InfoRow('الرصيد','${a.balance.toStringAsFixed(2)} جنيه')]))])); }}
class CardBox extends StatelessWidget { final List<Widget> children; const CardBox({super.key, required this.children}); @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8)]), child: Column(children: children)); }
class InfoRow extends StatelessWidget { final String label,value; const InfoRow(this.label,this.value,{super.key}); @override Widget build(BuildContext context)=>Container(padding: const EdgeInsets.symmetric(horizontal:16, vertical:15), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffeeeeee)))), child: Row(children:[Text(label, style: const TextStyle(color: Colors.grey, fontSize:15)), const Spacer(), Flexible(child: Text(value, textAlign: TextAlign.left, style: const TextStyle(color: darkText, fontSize:16, fontWeight: FontWeight.w600)))])); }

class TransferPage extends StatelessWidget { const TransferPage({super.key}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, body: Column(children:[const TopBar('تحويلات'), Expanded(child: ListView(padding: const EdgeInsets.all(16), children:[ActionTile('تحويل لحساب داخل البنك','assets/img/ftothacc.png',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const TransferBankPage()))), ActionTile('تحويل لموبايل','assets/img/ftmobileacc.png',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const TransferBankPage())))]))])); }
class ActionTile extends StatelessWidget { final String title, asset; final VoidCallback onTap; const ActionTile(this.title,this.asset,this.onTap,{super.key}); @override Widget build(BuildContext context)=>InkWell(onTap:onTap, child: Container(margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: lightBorder), borderRadius: BorderRadius.circular(10)), child: Row(children:[Image.asset(asset,width:38,errorBuilder:(_,__,___)=>const Icon(Icons.compare_arrows,color:red2)), const SizedBox(width:14), Expanded(child: Text(title,style: const TextStyle(fontSize:17))), const Icon(Icons.chevron_left)]))); }
class TransferBankPage extends StatefulWidget { const TransferBankPage({super.key}); @override State<TransferBankPage> createState()=>_TransferBankPageState(); }
class _TransferBankPageState extends State<TransferBankPage>{ final to=TextEditingController(), amount=TextEditingController(), mobile=TextEditingController(), comment=TextEditingController(); String error=''; void submit(){ final sender=current??accounts.values.first; final rec=accounts[to.text.trim()]; final amt=double.tryParse(amount.text.trim().replaceAll(',',''))??0; if(rec==null){setState(()=>error='الحساب المستلم غير موجود');return;} if(amt<=0){setState(()=>error='أدخل مبلغ صحيح');return;} if(sender.balance<amt){setState(()=>error='فشل التحويل: الرصيد غير كافي');return;} sender.balance-=amt; rec.balance+=amt; final t=Txn(id:'${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(90)+10}', from: sender.account, to: rec.account, toName: rec.name, mobile: mobile.text.trim().isEmpty?'N/A':mobile.text.trim(), comment: comment.text.trim().isEmpty?'N/A':comment.text.trim(), amount: amt, time: DateTime.now()); txns.insert(0,t); Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>SuccessPage(txn:t))); } @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.white, body:Column(children:[const TopBar('تحويل لحساب'), Expanded(child:SingleChildScrollView(padding:const EdgeInsets.all(18), child:Column(children:[FieldBox(controller:to,hint:'أدخل رقم حساب المستلم',icon:Icons.account_balance,keyboard:TextInputType.number), const SizedBox(height:14), FieldBox(controller:amount,hint:'المبلغ',icon:Icons.money,keyboard:TextInputType.number), const SizedBox(height:14), FieldBox(controller:mobile,hint:'رقم الموبايل أو N/A',icon:Icons.phone,keyboard:TextInputType.phone), const SizedBox(height:14), FieldBox(controller:comment,hint:'التعليق',icon:Icons.comment), const SizedBox(height:25), ElevatedButton(onPressed:submit, style:ElevatedButton.styleFrom(backgroundColor:red2, minimumSize:const Size(double.infinity,58), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))), child:const Text('إرسال',style:TextStyle(fontSize:20,color:Colors.white))), const SizedBox(height:12), Text(error,style:const TextStyle(color:red2,fontWeight:FontWeight.bold))])))])); }

class SuccessPage extends StatelessWidget { final Txn txn; const SuccessPage({super.key, required this.txn}); String dt(DateTime d)=>'${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; @override Widget build(BuildContext context)=>Scaffold(body:Container(decoration:const BoxDecoration(color:Color(0xff0b9b58), image:DecorationImage(image:AssetImage('assets/img/notify_bg.png'),fit:BoxFit.cover)), child:SafeArea(child:Column(children:[const SizedBox(height:34), Container(width:78,height:78,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.white,width:5)),child:const Icon(Icons.check,color:Colors.white,size:48)), const SizedBox(height:28), Padding(padding:const EdgeInsets.symmetric(horizontal:22), child:CardBox(children:[InfoRow('رقم العملية',txn.id),InfoRow('التاريخ والزمن',dt(txn.time)),InfoRow('من حساب',txn.from),InfoRow('إلى حساب',txn.to),InfoRow('إسم المرسل إليه',txn.toName),InfoRow('رقم الموبايل',txn.mobile),InfoRow('التعليق',txn.comment),InfoRow('المبلغ','${txn.amount.toStringAsFixed(2)} جنيه')])), const Spacer(), Padding(padding:const EdgeInsets.symmetric(horizontal:35), child:Row(children:[Expanded(child:OutlinedButton(onPressed:()=>showDialog(context:context,builder:(_)=>AlertDialog(content:const Text('قريبا...'), actions:[TextButton(onPressed:()=>Navigator.pop(context), child:const Text('موافق'))])), child:const Text('طباعة',style:TextStyle(color:Colors.white)))), const SizedBox(width:16), Expanded(child:ElevatedButton(onPressed:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const TransferBankPage()),(r)=>false), style:ElevatedButton.styleFrom(backgroundColor:Colors.white), child:const Text('موافق',style:TextStyle(color:Color(0xff0b9b58),fontWeight:FontWeight.bold))))])), const SizedBox(height:28)])))); }
class TransactionsPage extends StatelessWidget { const TransactionsPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xfff6f6f6), body:Column(children:[const TopBar('المعاملات السابقة'), Expanded(child:txns.isEmpty?const Center(child:Text('لا توجد معاملات سابقة')):ListView.builder(padding:const EdgeInsets.all(12), itemCount:txns.length, itemBuilder:(_,i){final t=txns[i]; return ActionTile('تحويل إلى ${t.toName} - ${t.amount.toStringAsFixed(2)} جنيه','assets/img/trxhisothft.png',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>SuccessPage(txn:t))));}))])); }
class ComingSoonPage extends StatelessWidget { final String title; const ComingSoonPage({super.key,required this.title}); @override Widget build(BuildContext context)=>Scaffold(body:Column(children:[TopBar(title), const Expanded(child:Center(child:Text('قريبا...',style:TextStyle(fontSize:25,color:Colors.grey))))])); }
class AdminPage extends StatefulWidget { const AdminPage({super.key}); @override State<AdminPage> createState()=>_AdminPageState(); }
class _AdminPageState extends State<AdminPage>{ final u=TextEditingController(),p=TextEditingController(),acc=TextEditingController(),name=TextEditingController(),bal=TextEditingController(); bool ok=false; void add(){ if(acc.text.isEmpty)return; accounts[acc.text.trim()]=Account(account:acc.text.trim(),password:'1234',name:name.text.trim().isEmpty?'عميل جديد':name.text.trim(),iban:'SD213724000000${acc.text.trim()}',balance:double.tryParse(bal.text.trim())??0); setState((){}); } @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.white, body:Column(children:[const TopBar('لوحة الأدمن'), Expanded(child:SingleChildScrollView(padding:const EdgeInsets.all(16), child: ok?Column(children:[FieldBox(controller:acc,hint:'رقم الحساب الجديد',icon:Icons.numbers),const SizedBox(height:12),FieldBox(controller:name,hint:'إسم صاحب الحساب',icon:Icons.person),const SizedBox(height:12),FieldBox(controller:bal,hint:'الرصيد',icon:Icons.money),const SizedBox(height:12),ElevatedButton(onPressed:add,style:ElevatedButton.styleFrom(backgroundColor:red2,minimumSize:const Size(double.infinity,55)),child:const Text('إضافة حساب',style:TextStyle(color:Colors.white))),const SizedBox(height:18),...accounts.values.map((a)=>InfoRow(a.account,'${a.name} - ${a.balance.toStringAsFixed(2)}'))]):Column(children:[FieldBox(controller:u,hint:'إسم المستخدم',icon:Icons.admin_panel_settings),const SizedBox(height:12),FieldBox(controller:p,hint:'كلمة المرور',icon:Icons.lock,obscure:true),const SizedBox(height:12),ElevatedButton(onPressed:(){if(u.text=='admin'&&p.text=='admin1234')setState(()=>ok=true);},style:ElevatedButton.styleFrom(backgroundColor:red2,minimumSize:const Size(double.infinity,55)),child:const Text('دخول',style:TextStyle(color:Colors.white)))]) ))])); }}
