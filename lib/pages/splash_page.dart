import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/pages/home_page.dart';
import 'package:architect_schwarz_admin/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatelessWidget {
  Future<void> _redirect(BuildContext context) async {
    // Zasymulowany opóźniony czas ładowania, aby zobaczyć CircularProgressIndicator
    // await Future.delayed(const Duration(seconds: 2));
    final session = await Supabase.instance.client.auth.currentSession;
    if (session != null) {
      //go to homepage
      Get.off(() => HomePage());
    } else {
      Get.off(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    _redirect(context);
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) {
    //     _redirect(context);
    //   },
    // )
    ;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
