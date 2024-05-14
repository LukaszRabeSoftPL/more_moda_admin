import 'package:architect_schwarz_admin/pages/article_page.dart';
import 'package:architect_schwarz_admin/widgets/tiles_menu.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'categories_page.dart';

import 'companies_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Indeks wybranej pozycji
  final List<Widget> _pages = const [
    CategoriesPage(),
    ArticlesPage(),
    CompaniesPage(),
  ];

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Admin Panel')),
      body: Row(
        children: [
          Container(
            width: 200, // Szerokość menu
            color: Colors.grey[200], // Tło menu
            child: ListView(
              children: [
                MenuItem(
                  title: 'Categories',
                  selected: _selectedIndex == 0,
                  onTap: () => _navigateTo(0),
                ),
                MenuItem(
                  title: 'Articles',
                  selected: _selectedIndex == 1,
                  onTap: () => _navigateTo(1),
                ),
                MenuItem(
                  title: 'Companies',
                  selected: _selectedIndex == 2,
                  onTap: () => _navigateTo(2),
                ),
                Divider(),
                MenuItem(
                  title: 'Logout',
                  selected: false,
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    Navigator.of(context).pushReplacementNamed('/loginPage');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _pages[
                _selectedIndex], // Zawartość zmienia się w zależności od wyboru w menu
          ),
        ],
      ),
    );
  }
}
