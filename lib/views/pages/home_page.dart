import 'package:architect_schwarz_admin/controllers/articles_a_z_controller.dart';
import 'package:architect_schwarz_admin/controllers/main_categories_controller.dart';
import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/pages/articles/article_az_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/categories_page.dart';
import 'package:architect_schwarz_admin/views/pages/companies/companies_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/companies_page.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/add_galery_2.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/gallery_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/login_page.dart';
import 'package:architect_schwarz_admin/views/pages/sub_subcategories/sub_subcategories_list_page.dart';
import 'package:architect_schwarz_admin/views/pages/subcategories_page.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200, // szerokość bocznego menu
            color: Color(0xFF6A93C3), // kolor tła menu
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
                    // _buildMenuItem(
                    //   index: 6,
                    //   icon: Icons.subject_outlined,
                    //   text: 'SubUnterkategorie',
                    // ),
                    _buildMenuItem(
                      index: 2,
                      icon: Icons.article,
                      text: 'Artikel',
                    ),
                    _buildMenuItem(
                      index: 3,
                      icon: Icons.photo_album,
                      text: 'Galerien',
                    ),
                    _buildMenuItem(
                      index: 5,
                      icon: Icons.business,
                      text: 'Firmen',
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
                    child: Container(
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
                GalerryListPage(),
                AddGalery2(),
                CompaniesListPage(),
                SubSubCategoriesListPage(),

                //CompaniesPage(),
              ],
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return SimpleDialog(
      //           title: Text('Add new category'),
      //           children: [
      //             TextFormField(
      //               onFieldSubmitted: (value) {
      //                 createMainCategories(value);
      //                 if (value.isNotEmpty) {
      //                   Navigator.pop(context);
      //                 } else {
      //                   Navigator.pop(context);
      //                 }
      //               },
      //             )
      //           ],
      //         );
      //       },
      //     );
      //     // await Supabase.instance.client.auth.signOut();
      //     // Get.offAll(() => LoginScreen());
      //   },
      //   child: Icon(Icons.exit_to_app),
      //   tooltip: 'Logout',
      // ),
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
}
