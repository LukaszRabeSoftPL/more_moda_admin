import 'package:architect_schwarz_admin/controllers/subcategories_controller.dart';
import 'package:architect_schwarz_admin/views/widgets/add_subcategory_bauteile.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:architect_schwarz_admin/views/widgets/popup_add.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubCategoriesPage extends StatefulWidget {
  const SubCategoriesPage({super.key});

  @override
  State<SubCategoriesPage> createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  //subabase instance
  SupabaseClient client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Stream for categories Bauteile
    final streamBauteileCategory = client
        .from('subcategories_main_categories')
        .stream(primaryKey: ['id'])
        .eq('main_category_id', '1')
        .order('id', ascending: true);

    //Stream for categories Baustoffe
    final streamBaustoffeCategory = client
        .from('subcategories_main_categories')
        .stream(primaryKey: ['id'])
        .eq('main_category_id', '2')
        .order('id', ascending: true);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //!Column for categories Bauteile
          Expanded(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Bauteile Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                Expanded(
                  child: StreamBuilder(
                    stream: streamBauteileCategory,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final categoriesBauteile = snapshot.data!;

                      return ListView.builder(
                        itemCount: categoriesBauteile?.length,
                        itemBuilder: (context, index) {
                          final categoryBauteile = categoriesBauteile[index];
                          final categoryBauteileId = categoryBauteile['id'];
                          return ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          final TextEditingController
                                              controller =
                                              TextEditingController(
                                                  text: categoryBauteile?[
                                                      'name']);
                                          return SimpleDialog(
                                            title: const Text(
                                                'Change category name'),
                                            children: [
                                              TextFormField(
                                                controller: controller,
                                                // initialValue:
                                                //     categoryBauteile?['name'],
                                                onFieldSubmitted:
                                                    (value) async {
                                                  //!tutaj wklej kod
                                                  updateSubCategoryBauteile(
                                                      categoryBauteileId,
                                                      value);

                                                  if (mounted)
                                                    Navigator.pop(context);
                                                  setState(() {});
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  },
                                ),
                                IconButton(
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                  ),
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    bool isConfirmed = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Delete category'),
                                          content: Text(
                                              'Are you sure you want to delete ${categoryBauteile?['name']} category?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: Text('NO'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: Text('YES'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (isConfirmed) {
                                      await deleteSubCategoryBauteile(
                                          categoryBauteileId);
                                      setState(() {
                                        // ignore: avoid_print
                                        print('refresh deleted categories');
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            leading: Text((index + 1).toString()),
                            title:
                                Text(categoryBauteile?['name'].toUpperCase()),
                          );
                        },
                      );
                    },
                  ),
                ),
                customButton(
                  text: 'add category',
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return addSubcategoryBauteile();
                      },
                    );
                    setState(() {
                      // ignore: avoid_print
                      print('refresh categories');
                    });
                  },
                )
              ],
            ),
          ),
          VerticalDivider(),
          //!Column for categories Baustoffe
          Expanded(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Baustoffe Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                Expanded(
                  child: StreamBuilder(
                    stream: streamBaustoffeCategory,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final categoriesBaustoffe = snapshot.data;

                      return ListView.builder(
                        itemCount: categoriesBaustoffe?.length,
                        itemBuilder: (context, index) {
                          final categoryBaustoffe = categoriesBaustoffe?[index];
                          return ListTile(
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            leading: Text((index + 1).toString()),
                            title:
                                Text(categoryBaustoffe?['name'].toUpperCase()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
