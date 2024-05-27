import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? keyCategories}) : super(key: keyCategories);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    refreshCategories();
  }

  Future<void> refreshCategories() async {
    // Logika pobierania kategorii
    // Uaktualnij stan, gdy dane zostaną pobrane
    setState(() {
      // przykładowa aktualizacja danych
      categories = [
        {'id': 1, 'name': 'Category 1'},
        {'id': 2, 'name': 'Category 2'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['name']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => {}, // logika edycji kategorii
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => {}, // logika usuwania kategorii
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
