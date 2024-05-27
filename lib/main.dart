import 'package:architect_schwarz_admin/pages/home_page.dart';
import 'package:architect_schwarz_admin/pages/login_page.dart';
import 'package:architect_schwarz_admin/pages/splash_page.dart';
import 'package:architect_schwarz_admin/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sizswbwqfigruaybljbk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpenN3YndxZmlncnVheWJsamJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ5OTg5ODksImV4cCI6MjAzMDU3NDk4OX0.BEzd2rPR2r9_eM2g1_7H-cfb-HebHZ2IlKjo6IvQRmM',
    debug: true,
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashPage(),
      getPages: [
        GetPage(name: '/splashpage', page: () => SplashPage()),
        GetPage(name: '/loginpage', page: () => LoginScreen()),
        GetPage(name: '/homepage', page: () => HomePage()),
      ],
      title: 'Flutter Admin Panel22',
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
