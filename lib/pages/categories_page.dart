import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> categoryNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchCategories();
  }

  //fetch cateegories from main_categories table
  Future<List> _fetchCategories() async {
    final response = await supabase
        .from('main_categories')
        .select('name')
        .withConverter((list) {
      return list.map((data) => data['name'] as String).toList();
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        categoryNames = List.from(response);
      });
    });

    //print(response.toString());
    //.eq('owner_id', userId)
    ;
    return response;
  }

  //delete category from main_categories table
  Future<void> _deleteCategory(int id) async {
    final response =
        await supabase.from('main_categories').delete().match({'id': id});
    print(response.toString());
  }

  //confirmation delete categoru
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this category?'),
          actions: <Widget>[
            MainButton(
              text: 'NO',
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.green,
              width: 80,
            ),
            MainButton(
              text: 'YES',
              onPressed: () {
                _deleteCategory(id);
                Navigator.of(context).pop();
              },
              color: Colors.red,
              width: 80,
            ),
          ],
        );
      },
    );
  }

  //edit category
  void _editCategory(int id, String name) {
    // Implement editing functionality
  }

  //add category
  void _addCategory() {
    // Implement add functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Categories')),
        body: Text(
          categoryNames.length
              .toString(), // Display the number of categories in the database
        ));
  }
}
