import 'package:more_moda_admin/main.dart';
import 'package:more_moda_admin/views/pages/home_page.dart';
import 'package:more_moda_admin/static/sizes_helpers.dart';
import 'package:more_moda_admin/static/static.dart';
import 'package:more_moda_admin/views/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();
  SupabaseClient client = Supabase.instance.client;
  double displayHeight(BuildContext context) {
    return displaySize(context).height;
  }

  double displayWidth(BuildContext context) {
    return displaySize(context).width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            width: 400,
            height: double.maxFinite,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border(
                right: BorderSide(
                  color: Colors.blue.shade300,
                  width: 1,
                ),
              ),
              color: Color(0xFF3a4d45),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/$logo', width: 200, height: 200),
                SizedBox(height: 20),
                Text(
                  'Willkommen zurück',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'admin panel',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 50),
                TextField(
                  controller: _emailController,
                  decoration: textFieldDecoration.copyWith(
                    labelText: 'E-mail',
                    floatingLabelStyle: TextStyle(color: Colors.white),
                    labelStyle:
                        TextStyle(color: Colors.white), // <-- biała etykieta
                  ),
                  style: TextStyle(
                    color: Colors
                        .white, // kolor tekstu wpisywanego przez użytkownika
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  // key: Key('password-field'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: textFieldDecoration.copyWith(
                    floatingLabelStyle: TextStyle(color: Colors.white),
                    labelText: 'Passwort',
                    labelStyle:
                        TextStyle(color: Colors.white), // <-- biała etykieta
                  ),
                  style: TextStyle(
                    color: Colors
                        .white, // kolor tekstu wpisywanego przez użytkownika
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 50,
                  child: MainButton(
                    text: 'Anmeldung',
                    onPressed: () async {
                      try {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'E-Mail und Passwort dürfen nicht leer sein.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final response = await client.auth.signInWithPassword(
                            email: email, password: password);

                        if (response.user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Einloggen erfolgreich'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Get.to(() => HomePage());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Einloggen fehlgeschlagen. Bitte versuchen Sie es erneut.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Ein Fehler ist aufgetreten: ${error.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Align(
                //     alignment: AlignmentDirectional.bottomEnd,
                //     child: Text('1.0')),
              ],
            ),
          ),
          Container(
            width: displayWidth(context) - 400,
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back_more_moda.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
