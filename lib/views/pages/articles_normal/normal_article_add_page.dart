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
  int? selectedGalleryId;
  String selectedGalleryName = '';
  bool isHtmlView = false;

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
      print('Fehler beim Laden der Hauptkategorien: $error');
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
      print('Fehler beim Laden der Unterkategorien: $error');
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
      print('Fehler beim Laden der Sub-Unterkategorien: $error');
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
      print('Fehler beim Hinzufügen des Artikels: $error');
    }
  }

  Future<void> _selectGallery() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGalleryPage(),
      ),
    );
    if (result != null) {
      setState(() {
        selectedGalleryId = result['id'];
        selectedGalleryName = result['name'];
      });
      htmlEditorController.insertHtml(
          '<popup id="$selectedGalleryId">$selectedGalleryName</popup>');
    }
  }

  void showHtmlEditorDialog() async {
    String currentText = bodyController.text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Artikel bearbeiten'),
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
                customToolbarButtons: [
                  GestureDetector(
                    onTap: _selectGallery,
                    child: Icon(Icons.add_box),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isHtmlView = !isHtmlView;
                      });
                      htmlEditorController.toggleCodeView();
                    },
                    child: Icon(isHtmlView ? Icons.code_off : Icons.code),
                  ),
                ],
                defaultToolbarButtons: [
                  FontButtons(),
                  ColorButtons(),
                  ListButtons(),
                  ParagraphButtons(),
                ],
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
              child: Text('Speichern'),
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
                        showCategoryModal(context, 'Unterkategorie wählen',
                            subCategories, selectedSubCategory, (int? value) {
                          setState(() {
                            selectedSubCategory = value;
                            loadSubSubCategories(value!);
                          });
                        });
                      },
                      child: Text(selectedSubCategory == null
                          ? 'Unterkategorie wählen'
                          : subCategories.isNotEmpty
                              ? subCategories.firstWhere(
                                  (category) =>
                                      category['id'] == selectedSubCategory,
                                  orElse: () => {'name': 'N/A'})['name']
                              : 'Unterkategorie wählen'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showCategoryModal(
                            context,
                            'Sub-Unterkategorie wählen',
                            subSubCategories,
                            selectedSubSubCategory, (int? value) {
                          setState(() {
                            selectedSubSubCategory = value;
                          });
                        });
                      },
                      child: Text(selectedSubSubCategory == null
                          ? 'Sub-Unterkategorie wählen'
                          : subSubCategories.isNotEmpty
                              ? subSubCategories.firstWhere(
                                  (category) =>
                                      category['id'] == selectedSubSubCategory,
                                  orElse: () => {'name': 'N/A'})['name']
                              : 'Sub-Unterkategorie wählen'),
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
                labelText: 'Text',
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

class SelectGalleryPage extends StatefulWidget {
  @override
  _SelectGalleryPageState createState() => _SelectGalleryPageState();
}

class _SelectGalleryPageState extends State<SelectGalleryPage> {
  List<Map<String, dynamic>> galleries = [];
  int? selectedGalleryId;

  @override
  void initState() {
    super.initState();
    _loadGalleries();
  }

  Future<void> _loadGalleries() async {
    try {
      SupabaseClient client = Supabase.instance.client;
      final List<dynamic> response =
          await client.from('galerries').select('id, name');

      setState(() {
        galleries = response.cast<Map<String, dynamic>>();
      });
    } catch (error) {
      // Fehlerbehandlung
      print("Fehler beim Laden der Galerien: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galerie auswählen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<int>(
              hint: Text('Galerie auswählen'),
              value: selectedGalleryId,
              onChanged: (int? newValue) {
                setState(() {
                  selectedGalleryId = newValue;
                });
              },
              items: galleries.map((gallery) {
                return DropdownMenuItem<int>(
                  value: gallery['id'],
                  child: Text(gallery['name']),
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Abbrechen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    if (selectedGalleryId != null) {
                      Navigator.of(context).pop({
                        'id': selectedGalleryId,
                        'name': galleries.firstWhere((gallery) =>
                            gallery['id'] == selectedGalleryId)['name']
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
