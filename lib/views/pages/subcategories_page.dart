import 'package:architect_schwarz_admin/controllers/subcategories_controller.dart';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/widgets/add_subcategory_baustoffe.dart';
import 'package:architect_schwarz_admin/views/widgets/add_subcategory_bauteile.dart';
import 'package:architect_schwarz_admin/views/widgets/add_subcategory_gestaltung.dart';
import 'package:architect_schwarz_admin/views/widgets/add_subcategory_plannung.dart';
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
  String newSubCategoryName = '';
  int categoryId = 0;

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

    // Stream for categories Gestaltung
    final streamGestaltungCategory = client
        .from('subcategories_main_categories')
        .stream(primaryKey: ['id'])
        .eq('main_category_id', '3')
        .order('id', ascending: true);

    // Stream for categories Planung
    final streamPlanungCategory = client
        .from('subcategories_main_categories')
        .stream(primaryKey: ['id'])
        .eq('main_category_id', '4')
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
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Bauteile Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            color: cardColor,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: buttonColor,
                                    ),
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
                                                  'Kategorienamen ändern'),
                                              children: [
                                                Divider(
                                                  thickness: 1,
                                                  color: buttonColor,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    onChanged: (value) => {
                                                      newSubCategoryName =
                                                          value,
                                                      categoryId =
                                                          categoryBauteileId,
                                                    },
                                                    controller: controller,
                                                    onFieldSubmitted:
                                                        (value) async {
                                                      updateSubCategoryBauteile(
                                                          categoryBauteileId,
                                                          value);

                                                      if (mounted)
                                                        Navigator.pop(context);
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: customButton(
                                                    text: 'Speichern',
                                                    onPressed: () async {
                                                      await updateSubCategoryBauteile(
                                                          categoryId,
                                                          newSubCategoryName);
                                                      setState(
                                                          () {}); // Upewnij się, że stan jest zaktualizowany
                                                      Navigator.pop(
                                                          context); // Zamknij dialog
                                                    },
                                                  ),
                                                ),
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
                                            title: Text('Kategorie löschen'),
                                            content: Text(
                                                'Sind Sie sicher, dass Sie löschen möchten ${categoryBauteile?['name']} Kategorie?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: Text('NEIN'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Container(
                                                  width: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .delete_forever_sharp,
                                                          color: Colors.white,
                                                          size: 20),
                                                      SizedBox(width: 5),
                                                      const Text('JA'),
                                                    ],
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
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
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                    text: 'Unterkategorie hinzufügen',
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
                  ),
                ),
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
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Baustoffe Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
                          final categoryBaustoffeId = categoryBaustoffe?['id'];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            color: cardColor,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: buttonColor,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final TextEditingController
                                              controller =
                                              TextEditingController(
                                                  text: categoryBaustoffe?[
                                                      'name']);
                                          return SimpleDialog(
                                            title: Text(
                                              'Kategorienamen ändern',
                                              style: TextStyle(
                                                color: buttonColor,
                                              ),
                                            ),
                                            children: [
                                              Divider(
                                                thickness: 1,
                                                color: buttonColor,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  controller: controller,
                                                  onChanged: (value) {
                                                    newSubCategoryName = value;
                                                    categoryId =
                                                        categoryBaustoffeId;
                                                  },
                                                  onFieldSubmitted:
                                                      (value) async {
                                                    updateSubCategoryBaustoffe(
                                                        categoryBaustoffeId,
                                                        value);

                                                    if (mounted)
                                                      Navigator.pop(context);
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: customButton(
                                                  text: 'Speichern',
                                                  onPressed: () async {
                                                    await updateSubCategoryBaustoffe(
                                                        categoryId,
                                                        newSubCategoryName);
                                                    setState(
                                                        () {}); // Upewnij się, że stan jest zaktualizowany
                                                    Navigator.pop(
                                                        context); // Zamknij dialog
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
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
                                            title: Text('Kategorie löschen'),
                                            content: Text(
                                                'Sind Sie sicher, dass Sie löschen möchten ${categoryBaustoffe?['name']} Kategorie?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: Text('NEIN'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Container(
                                                  width: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .delete_forever_sharp,
                                                          color: Colors.white,
                                                          size: 20),
                                                      SizedBox(width: 5),
                                                      const Text('JA'),
                                                    ],
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (isConfirmed) {
                                        await deleteSubCategoryBaustoffe(
                                            categoryBaustoffeId);
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
                              title: Text(
                                  categoryBaustoffe?['name'].toUpperCase()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                    text: 'Unterkategorie hinzufügen',
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AddSubcategoryBaustoffe();
                        },
                      );
                      setState(() {
                        // ignore: avoid_print
                        print('refresh categories');
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(),
          //!Column for categories Gestaltung
          Expanded(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Gestaltung Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: StreamBuilder(
                    stream: streamGestaltungCategory,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final categoriesGestaltung = snapshot.data!;

                      return ListView.builder(
                        itemCount: categoriesGestaltung?.length,
                        itemBuilder: (context, index) {
                          final categoryGestaltung =
                              categoriesGestaltung[index];
                          final categoryGestaltungId = categoryGestaltung['id'];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            color: cardColor,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: buttonColor,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            final TextEditingController
                                                controller =
                                                TextEditingController(
                                                    text: categoryGestaltung?[
                                                        'name']);
                                            return SimpleDialog(
                                              title: const Text(
                                                  'Kategorienamen ändern'),
                                              children: [
                                                Divider(
                                                  thickness: 1,
                                                  color: buttonColor,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    onChanged: (value) => {
                                                      newSubCategoryName =
                                                          value,
                                                      categoryId =
                                                          categoryGestaltungId,
                                                    },
                                                    controller: controller,
                                                    onFieldSubmitted:
                                                        (value) async {
                                                      updateSubCategoryBauteile(
                                                          categoryGestaltungId,
                                                          value);

                                                      if (mounted)
                                                        Navigator.pop(context);
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: customButton(
                                                    text: 'Speichern',
                                                    onPressed: () async {
                                                      await updateSubCategoryBauteile(
                                                          categoryId,
                                                          newSubCategoryName);
                                                      setState(
                                                          () {}); // Upewnij się, że stan jest zaktualizowany
                                                      Navigator.pop(
                                                          context); // Zamknij dialog
                                                    },
                                                  ),
                                                ),
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
                                            title: Text('Kategorie löschen'),
                                            content: Text(
                                                'Sind Sie sicher, dass Sie löschen möchten ${categoryGestaltung?['name']} Kategorie?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: Text('NEIN'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Container(
                                                  width: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .delete_forever_sharp,
                                                          color: Colors.white,
                                                          size: 20),
                                                      SizedBox(width: 5),
                                                      const Text('JA'),
                                                    ],
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (isConfirmed) {
                                        await deleteSubCategoryBauteile(
                                            categoryGestaltungId);
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
                              title: Text(
                                  categoryGestaltung?['name'].toUpperCase()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                    text: 'Unterkategorie hinzufügen',
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AddSubcategoryGestaltung();
                        },
                      );
                      setState(() {
                        // ignore: avoid_print
                        print('refresh categories');
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(),
          //!Column for categories Planung
          Expanded(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Planung Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: StreamBuilder(
                    stream: streamPlanungCategory,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final categoriesPlanung = snapshot.data!;

                      return ListView.builder(
                        itemCount: categoriesPlanung?.length,
                        itemBuilder: (context, index) {
                          final categoryPlanung = categoriesPlanung[index];
                          final categoryPlanungId = categoryPlanung['id'];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            color: cardColor,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: buttonColor,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            final TextEditingController
                                                controller =
                                                TextEditingController(
                                                    text: categoryPlanung?[
                                                        'name']);
                                            return SimpleDialog(
                                              title: const Text(
                                                  'Kategorienamen ändern'),
                                              children: [
                                                Divider(
                                                  thickness: 1,
                                                  color: buttonColor,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    onChanged: (value) => {
                                                      newSubCategoryName =
                                                          value,
                                                      categoryId =
                                                          categoryPlanungId,
                                                    },
                                                    controller: controller,
                                                    onFieldSubmitted:
                                                        (value) async {
                                                      updateSubCategoryBauteile(
                                                          categoryPlanungId,
                                                          value);

                                                      if (mounted)
                                                        Navigator.pop(context);
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: customButton(
                                                    text: 'Speichern',
                                                    onPressed: () async {
                                                      await updateSubCategoryBauteile(
                                                          categoryId,
                                                          newSubCategoryName);
                                                      setState(
                                                          () {}); // Upewnij się, że stan jest zaktualizowany
                                                      Navigator.pop(
                                                          context); // Zamknij dialog
                                                    },
                                                  ),
                                                ),
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
                                            title: Text('Kategorie löschen'),
                                            content: Text(
                                                'Sind Sie sicher, dass Sie löschen möchten ${categoryPlanung?['name']} Kategorie?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: Text('NEIN'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Container(
                                                  width: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .delete_forever_sharp,
                                                          color: Colors.white,
                                                          size: 20),
                                                      SizedBox(width: 5),
                                                      const Text('JA'),
                                                    ],
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (isConfirmed) {
                                        await deleteSubCategoryBauteile(
                                            categoryPlanungId);
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
                                  Text(categoryPlanung?['name'].toUpperCase()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                    text: 'Unterkategorie hinzufügen',
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AddSubcategoryPlannung();
                        },
                      );
                      setState(() {
                        // ignore: avoid_print
                        print('refresh categories');
                      });
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
