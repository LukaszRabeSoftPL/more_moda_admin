import 'package:architect_schwarz_admin/pages/categories_page.dart';
import 'package:architect_schwarz_admin/pages/companies_page.dart';
import 'package:architect_schwarz_admin/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200, // szerokość bocznego menu
            color: Colors.grey[200], // kolor tła menu
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Kategorie'),
                  onTap: () {
                    pageController.jumpToPage(0);
                  },
                ),
                ListTile(
                  title: Text('Subkategorie'),
                  onTap: () {
                    pageController.jumpToPage(1);
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Wyloguj'),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    Get.offAll(() => LoginScreen());
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                CategoriesPage(),
                CompaniesPage(),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          Get.offAll(() => LoginScreen());
        },
        child: Icon(Icons.exit_to_app),
        tooltip: 'Logout',
      ),
    );
  }
}
