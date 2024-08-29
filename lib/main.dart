import 'package:architect_schwarz_admin/routes/app_routes.dart';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/pages/categories_page.dart';
import 'package:architect_schwarz_admin/views/pages/home_page.dart';
import 'package:architect_schwarz_admin/views/pages/login_page.dart';
import 'package:architect_schwarz_admin/views/pages/splash_page.dart';
import 'package:architect_schwarz_admin/views/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); //wait load env

  String supaUri = dotenv.get('SUPABASE_URL'); //get env key
  String supaAnon = dotenv.get('SUPABASE_ANONKEY');
  String appName = dotenv.get('APP_NAME');

  await Supabase.initialize(
    url: supaUri,
    anonKey: supaAnon,
  );

  runApp(MyApp(appName: appName));
}

SupabaseClient supabaseClient = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final String appName;

  const MyApp({Key? key, required this.appName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialRoute = Supabase.instance.client.auth.currentUser != null
        ? RoutesClass.getHomeRoute()
        : RoutesClass.getLoginPageRoute();

    return GetMaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: TextStyle(
            //kolor etykiety
            color: Colors.black,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: buttonColor),
          ),
        ),
        // Styl dla TextField
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Kolor czcionki
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor, // Kolor tła przycisku
            foregroundColor: Colors.white, // Kolor tekstu przycisku
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: buttonColor2, // Kolor tła
          ),
        ),
      ),
      title: appName,
      initialRoute: initialRoute, //cek login current user,
      getPages: RoutesClass.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}









//  initialRoute: await Get.toNamed(RoutesClass.getHomeRoute()),
      
      // supaProvider.client.auth.currentUser == null
      //     ? await Get.toNamed(RoutesClass.getLoginPageRoute())
      //     : await Get.toNamed(
      //         RoutesClass.getHomeRoute()), //cek login current user





//! PART OLD 
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load();

//   String supaUri = dotenv.get('SUPABASE_URL');
//   String supaAnon = dotenv.get('SUPABASE_ANON_KEY');

//   Supabase supaProvider = await Supabase.initialize(
//     url: supaUri,
//     anonKey: supaAnon,
//   );

  // await Supabase.initialize(
  //   url: 'https://sizswbwqfigruaybljbk.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpenN3YndxZmlncnVheWJsamJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ5OTg5ODksImV4cCI6MjAzMDU3NDk4OX0.BEzd2rPR2r9_eM2g1_7H-cfb-HebHZ2IlKjo6IvQRmM',
  //   debug: true,
  // );
//   runApp(MyApp());
// }

// final supabase = Supabase.instance.client;

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: SplashPage(),
//       getPages: [
//         GetPage(name: '/', page: () => SplashPage()),
//         // GetPage(name: '/splashpage', page: () => SplashPage()),
//         GetPage(name: '/loginpage', page: () => LoginScreen()),
//         GetPage(name: '/homepage', page: () => HomePage()),
//         GetPage(name: '/categoryPage', page: () => CategoriesPage()) 
//       ],
//       title: 'Flutter Admin Panel22',
//       theme: lightMode,
//       darkTheme: darkMode,
//     );
//   }
// }
