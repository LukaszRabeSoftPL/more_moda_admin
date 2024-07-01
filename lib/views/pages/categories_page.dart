import 'package:architect_schwarz_admin/controllers/main_categories_controller.dart';
import 'package:architect_schwarz_admin/main.dart';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:architect_schwarz_admin/views/widgets/main_button.dart';
import 'package:architect_schwarz_admin/views/widgets/popup_add.dart';
import 'package:flutter/material.dart';
import 'package:postgrest/src/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? keyCategories}) : super(key: keyCategories);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  SupabaseClient client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  Future<List> getCategories() async {
    final readData = await client.from('main_categories').select('name');
    return readData;
  }

  @override
  Widget build(BuildContext context) {
    final mainCategoriesStream =
        supabaseClient.from('main_categories').stream(primaryKey: ['id']);

    return Scaffold(
        //appBar: AppBar(title: const Text('Categories')),

        //replace ListView.builder with FutureBuilder

        body: Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: customButton(
                text: 'Kategorie hinzufügen',
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AddMainCategoryCustomDialog();
                    },
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Divider(
          thickness: 1,
          color: Color(0xFF6A93C3).withOpacity(0.5),
        ),
        StreamBuilder(
          stream: mainCategoriesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final data = snapshot.data as List;
              return Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final category = data[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      color: cardColor,
                      child: ListTile(
                        leading: Text((index + 1).toString()),
                        title: Text(
                          category['name'],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Text(data[index].toString(),
                            //     style: const TextStyle(color: Colors.red)),

                            // IconButton(
                            //   icon: const Icon(Icons.edit),
                            //   onPressed: () => {
                            //     showDialog(
                            //       context: context,
                            //       builder: (context) {
                            //         return SimpleDialog(
                            //           title: Text('Edit name of category'),
                            //           children: [
                            //             TextFormField(
                            //               initialValue: category['name'],
                            //               onFieldSubmitted: (value) async {
                            //                 await updateMainCategories(
                            //                     category, value);
                            //                 if (mounted) {
                            //                   Navigator.pop(context);
                            //                 }
                            //               },
                            //             )
                            //           ],
                            //         );
                            //       },
                            //     )
                            //   }, // logika edycji kategorii
                            // ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                color: unactiveColor,
                                onPressed: () async {
                                  // bool deleteConfirmed = await showDialog(
                                  //   context: context,
                                  //   builder: (context) {
                                  //     return AlertDialog(
                                  //       title: const Text('Delete category'),
                                  //       actions: [
                                  //         TextButton(
                                  //             onPressed: () {
                                  //               Navigator.pop(context, false);
                                  //             },
                                  //             child: Text('No')),
                                  //         TextButton(
                                  //             onPressed: () {
                                  //               Navigator.pop(context, true);
                                  //             },
                                  //             child: Text('Yes')),
                                  //       ],
                                  //       content: Text(
                                  //           'Are you sure you want to delete ${category['name']}?'),
                                  //     );
                                  //   },
                                  // );
                                  // if (deleteConfirmed) {
                                  //   await deleteMainCategories(category);
                                  // }
                                }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    )

        // FutureBuilder(
        //   future: getCategories(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(child: CircularProgressIndicator());
        //     } else {
        //       final data = snapshot.data as List;
        //       return ListView.builder(
        //         itemCount: data.length,
        //         itemBuilder: (context, index) {
        //           final category = data[index];
        //           return ListTile(
        //             title: Text(category['name']),
        //             trailing: Row(
        //               mainAxisSize: MainAxisSize.min,
        //               children: [
        //                 // Text(data[index].toString(),
        //                 //     style: const TextStyle(color: Colors.red)),
        //                 IconButton(
        //                   icon: const Icon(Icons.edit),
        //                   onPressed: () => {}, // logika edycji kategorii
        //                 ),
        //                 IconButton(
        //                   icon: const Icon(Icons.delete),
        //                   color: Colors.red,
        //                   onPressed: () => {}, // logika usuwania kategorii
        //                 ),
        //               ],
        //             ),
        //           );
        //         },
        //       );
        //     }
        //   },
        );
  }
}
