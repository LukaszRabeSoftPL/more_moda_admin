import 'package:architect_schwarz_admin/controllers/articles_a_z_controller.dart';
import 'package:architect_schwarz_admin/controllers/main_categories_controller.dart';
import 'package:architect_schwarz_admin/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/pages/articles_a_z/article_az_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/articles_normal/article_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/categories_page.dart';
import 'package:architect_schwarz_admin/views/pages/companies/companies_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/companies_page.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/add_galery_2.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/gallery_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/login_page.dart';
import 'package:architect_schwarz_admin/views/pages/sub_subcategories/sub_subcategories_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/subcategories_page.dart';
import 'package:architect_schwarz_admin/views/pages/werbung/werbung_list_page.dart'; // Import nowego ekranu
import 'package:fancy_button_flutter/fancy_button_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController pageController = PageController();
  int _selectedIndex = 0;
  String versionNumber = dotenv.env['VERSION_NUMBER'] ?? 'Unknown version';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: Color(0xFF6A93C3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Image.asset('assets/images/$logo',
                          width: 90, height: 90),
                    ),
                    _buildMenuItem(
                      index: 0,
                      icon: Icons.category,
                      text: 'Hauptkategorien',
                    ),
                    _buildMenuItem(
                      index: 1,
                      icon: Icons.subdirectory_arrow_right,
                      text: 'Unterkategorie',
                    ),
                    _buildMenuItem(
                      index: 2,
                      icon: Icons.article,
                      text: 'Artikel A-Z',
                    ),
                    _buildMenuItem(
                      index: 3,
                      icon: Icons.article_outlined,
                      text: 'Artikel',
                    ),
                    _buildMenuItem(
                      index: 4,
                      icon: Icons.photo_album,
                      text: 'Galerien',
                    ),
                    _buildMenuItem(
                      index: 6,
                      icon: Icons.business,
                      text: 'Firmen',
                    ),
                    _buildMenuItem(
                      index: 7,
                      icon: Icons.web,
                      text: 'Werbung',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: GestureDetector(
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      Get.offAll(() => LoginScreen());
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'version number: 1.18.0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.red,
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text('Ausloggen',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: const [
                CategoriesPage(),
                SubCategoriesPage(),
                Article_AZ_ListPage(),
                NormalArticleListPage(),
                GalerryListPage(),
                AddGalery2(),
                CompaniesListPage(),
                WerbungListPage(), // Nowy ekran
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String text,
  }) {
    return Container(
      color: _selectedIndex == index ? Color(0xFFF8EB98) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon,
            color: _selectedIndex == index ? Color(0xFF838383) : Colors.white),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: _selectedIndex == index ? Color(0xFF838383) : Colors.white,
          ),
        ),
        onTap: () => _onItemTapped(index),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.jumpToPage(index);
    });
  }
}
