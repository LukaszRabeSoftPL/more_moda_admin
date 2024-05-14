import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/widgets/main_button.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _eamilController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _eamilController.dispose();
    _passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = supabase.auth.currentUser;
    if (!mounted) return;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/homePage');
    } else {
      Navigator.of(context).pushReplacementNamed('/loginPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 500,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 10,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text('Please login to continue.'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    child: TextFormField(
                      controller: _eamilController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  MainButton(
                      onPressed: () async {
                        try {
                          final email = _eamilController.text.trim();
                          final password = _passwordController.text.trim();
                          final response = await supabase.auth
                              .signInWithPassword(
                                  email: email, password: password);

                          if (response.user != null) {
                            // If the response includes a user object, login is successful
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login Success'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Redirect to product_info_page
                            Navigator.of(context)
                                .pushReplacementNamed('/homePage');
                          } else {
                            // If there's no user object, handle it as a failure
                            // This assumes failure, but you might want to refine this based on actual response details or exceptions
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Login failed, please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } on AuthException catch (error) {
                          // Catching AuthException specifically if it's thrown
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } catch (error) {
                          // Catching any other exceptions that might occur
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('An error occurred: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      text: 'Login')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
