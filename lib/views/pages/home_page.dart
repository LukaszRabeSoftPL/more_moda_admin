import 'package:architect_schwarz_admin/controllers/articles_a_z_controller.dart';
import 'package:architect_schwarz_admin/controllers/main_categories_controller.dart';
import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/views/pages/article_az_list_page.dart';

import 'package:architect_schwarz_admin/views/pages/categories_page.dart';
import 'package:architect_schwarz_admin/views/pages/companies_page.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/add_galery_2.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/gallery_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/login_page.dart';
import 'package:architect_schwarz_admin/views/pages/subcategories_page.dart';
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
                ListTile(
                  title: Text('Articles_A_Z'),
                  onTap: () {
                    pageController.jumpToPage(2);
                  },
                ),
                ListTile(
                  title: Text('Galerie'),
                  onTap: () {
                    pageController.jumpToPage(3);
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
              children: const [
                CategoriesPage(),
                SubCategoriesPage(),
                Article_AZ_ListPage(),
                GalerryListPage(),
                AddGalery2(),

                //CompaniesPage(),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('Add new category'),
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) {
                      createMainCategories(value);
                      if (value.isNotEmpty) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                      }

                      ;
                    },
                  )
                ],
              );
            },
          );
          // await Supabase.instance.client.auth.signOut();
          // Get.offAll(() => LoginScreen());
        },
        child: Icon(Icons.exit_to_app),
        tooltip: 'Logout',
      ),
    );
  }
}
