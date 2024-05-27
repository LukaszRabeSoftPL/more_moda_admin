import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/pages/home_page.dart';
import 'package:architect_schwarz_admin/static/sizes_helpers.dart';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

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
              border: Border(
                right: BorderSide(
                  color: Colors.blue.shade300,
                  width: 1,
                ),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/$logo', width: 200, height: 200),
                SizedBox(height: 50),
                TextField(
                  key: Key('email-field'),
                  controller: _emailController,
                  decoration: textFieldDecoration.copyWith(labelText: 'Email'),
                ),
                SizedBox(height: 20),
                TextField(
                  key: Key('password-field'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration:
                      textFieldDecoration.copyWith(labelText: 'Password'),
                ),
                SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: buttonStyle1,
                    onPressed: () async {
                      try {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Email and password cannot be empty.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final response = await supabase.auth.signInWithPassword(
                            email: email, password: password);

                        if (response.user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login Success'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Get.to(() => HomePage());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login failed, please try again.1'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('An error occurred: ${error.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text('Login'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: displayWidth(context) - 400,
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
