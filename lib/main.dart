import 'package:architect_schwarz_admin/pages/article_page.dart';
import 'package:architect_schwarz_admin/pages/categories_page.dart';
import 'package:architect_schwarz_admin/pages/companies_page.dart';
import 'package:architect_schwarz_admin/pages/home_page.dart';
import 'package:architect_schwarz_admin/pages/login_page.dart';
import 'package:architect_schwarz_admin/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ladfkgbzsfmzverxacdn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhZGZrZ2J6c2ZtenZlcnhhY2RuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA3ODM3NDMsImV4cCI6MjAyNjM1OTc0M30.j3f6_FfgmDOnKvVR8UMOOnY0pqNHNNzMMwT2FKMGxGE',
    debug: true,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Architect Schwarz admin panel',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashPage(),
          '/loginPage': (context) => const LoginPage(),
          '/homePage': (context) => const HomePage(),
          '/categoriesPage': (context) => const CategoriesPage(),
          '/companiesPage': (context) => const CompaniesPage(),
          '/articlesPage': (context) => const ArticlesPage(),
        });
  }
}
