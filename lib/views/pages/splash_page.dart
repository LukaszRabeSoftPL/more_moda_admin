import 'package:more_moda_admin/main.dart';
import 'package:more_moda_admin/views/pages/home_page.dart';
import 'package:more_moda_admin/views/pages/login_page.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase/supabase.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// class SplashPage extends StatelessWidget {
//   Future<void> _redirect(BuildContext context) async {
//     // Zasymulowany opóźniony czas ładowania, aby zobaczyć CircularProgressIndicator
//     await Future.delayed(const Duration(seconds: 2));
//     final session = Supabase.instance.client.auth.currentSession;
//     if (session != null) {
//       //go to homepage
//       Get.off(() => HomePage());
//     } else {
//       Get.off(() => LoginScreen());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _redirect(context);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _redirect(context);
//     });

//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const <Widget>[
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text('Loading...'),
//           ],
//         ),
//       ),
//     );
//   }
// }
