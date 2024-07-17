import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'dart:ui_web' as ui_web; // Update the import as suggested

class NormalArticleAddPage extends StatefulWidget {
  @override
  _NormalArticleAddPageState createState() => _NormalArticleAddPageState();
}

class _NormalArticleAddPageState extends State<NormalArticleAddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  HtmlEditorController htmlEditorController = HtmlEditorController();
  int? selectedMainCategory;
  int? selectedSubCategory;
  int? selectedSubSubCategory;

  List<Map<String, dynamic>> mainCategories = [];
  List<Map<String, dynamic>> subCategories = [];
  List<Map<String, dynamic>> subSubCategories = [];

  @override
  void initState() {
    super.initState();
    loadMainCategories();
  }

  Future<void> loadMainCategories() async {
    try {
      final response =
          await Supabase.instance.client.from('main_categories').select();
      setState(() {
        mainCategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Error loading main categories: $error');
    }
  }

  Future<void> loadSubCategories(int mainCategoryId) async {
    try {
      final response = await Supabase.instance.client
          .from('subcategories_main_categories')
          .select()
          .eq('main_category_id', mainCategoryId);
      setState(() {
        subCategories = List<Map<String, dynamic>>.from(response);
        selectedSubCategory = null;
        selectedSubSubCategory = null;
        subSubCategories = [];
      });
    } catch (error) {
      print('Error loading subcategories: $error');
    }
  }

  Future<void> loadSubSubCategories(int subCategoryId) async {
    try {
      final response = await Supabase.instance.client
          .from('sub_subcategories_main_categories')
          .select()
          .eq('sub_category_id', subCategoryId);
      setState(() {
        subSubCategories = List<Map<String, dynamic>>.from(response);
        selectedSubSubCategory = null;
      });
    } catch (error) {
      print('Error loading sub-subcategories: $error');
    }
  }

  Future<void> addArticle() async {
    try {
      String bodyHtml = bodyController.text;
      SupabaseClient client = Supabase.instance.client;
      await client.from('articles').insert({
        'title': titleController.text,
        'body': bodyHtml,
        'main_category_id': selectedMainCategory,
        'subcategory_id': selectedSubCategory,
        'sub_subcategory_id': selectedSubSubCategory,
      });
    } catch (error) {
      print('Error adding article: $error');
    }
  }

  void showHtmlEditorDialog() async {
    String currentText = bodyController.text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edytuj treść'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: HtmlEditor(
              controller: htmlEditorController,
              htmlEditorOptions: HtmlEditorOptions(
                hint: 'Dein Text hier...',
                initialText: currentText, // Ustawienie początkowego tekstu
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarType: ToolbarType.nativeScrollable,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String? updatedText = await htmlEditorController.getText();
                setState(() {
                  bodyController.text = updatedText ?? '';
                });
                Navigator.of(context).pop();
              },
              child: Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showCategoryModal(
      BuildContext context,
      String title,
      List<Map<String, dynamic>> items,
      int? selectedItem,
      void Function(int?) onItemSelected) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile<int>(
                title: Text(items[index]['name']),
                value: items[index]['id'],
                groupValue: selectedItem,
                onChanged: (int? value) {
                  onItemSelected(value);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel hinzufügen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      )),
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    showCategoryModal(context, 'Kategorie wählen',
                        mainCategories, selectedMainCategory, (int? value) {
                      setState(() {
                        selectedMainCategory = value;
                        loadSubCategories(value!);
                      });
                    });
                  },
                  child: Text(selectedMainCategory == null
                      ? 'Kategorie wählen'
                      : mainCategories.firstWhere(
                          (category) => category['id'] == selectedMainCategory,
                          orElse: () => {'name': 'N/A'})['name']),
                ),
              ],
            ),
            if (selectedMainCategory != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showCategoryModal(context, 'Podkategoria wählen',
                            subCategories, selectedSubCategory, (int? value) {
                          setState(() {
                            selectedSubCategory = value;
                            loadSubSubCategories(value!);
                          });
                        });
                      },
                      child: Text(selectedSubCategory == null
                          ? 'Podkategoria wählen'
                          : subCategories.isNotEmpty
                              ? subCategories.firstWhere(
                                  (category) =>
                                      category['id'] == selectedSubCategory,
                                  orElse: () => {'name': 'N/A'})['name']
                              : 'Podkategoria wählen'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showCategoryModal(
                            context,
                            'Sub-Podkategoria wählen',
                            subSubCategories,
                            selectedSubSubCategory, (int? value) {
                          setState(() {
                            selectedSubSubCategory = value;
                          });
                        });
                      },
                      child: Text(selectedSubSubCategory == null
                          ? 'Sub-Podkategoria wählen'
                          : subSubCategories.isNotEmpty
                              ? subSubCategories.firstWhere(
                                  (category) =>
                                      category['id'] == selectedSubSubCategory,
                                  orElse: () => {'name': 'N/A'})['name']
                              : 'Sub-Podkategoria wählen'),
                    ),
                  ),
                ],
              ),
            Divider(
              thickness: 1,
              color: Color(0xFF6A93C3).withOpacity(0.5),
            ),
            SizedBox(height: 20),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Treść',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: showHtmlEditorDialog,
            ),
            SizedBox(height: 16),
            customButton(
              text: 'Speichern',
              onPressed: () async {
                await addArticle();
                Navigator.pop(context, true); // Zwraca true po dodaniu artykułu
              },
            ),
          ],
        ),
      ),
    );
  }
}
