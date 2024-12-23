import 'package:architect_schwarz_admin/views/pages/articles_a_z/article_az_add_page.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  int? selectedParentArticleId;
  String selectedGalleryName = '';
  String selectedParentArticleTitle = '';
  bool isHtmlView = false;
  bool isSubArticle = false;

  List<Map<String, dynamic>> mainCategories = [];
  List<Map<String, dynamic>> subCategories = [];
  List<Map<String, dynamic>> subSubCategories = [];
  List<Map<String, dynamic>> allArticles = [];

  @override
  void initState() {
    super.initState();
    loadMainCategories();
    loadAllArticles();
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

  Future<void> loadAllArticles() async {
    try {
      final response = await Supabase.instance.client.from('articles').select(
          'id, title, main_categories(name), subcategories_main_categories(name), sub_subcategories_main_categories(name)');
      setState(() {
        allArticles = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Fehler beim Laden der Artikel: $error');
    }
  }

  Future<String?> _pickAndUploadPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict to PDF files
      );

      if (result == null || result.files.single.bytes == null) {
        return null; // User canceled or no file selected
      }

      final bytes = result.files.single.bytes!;
      final String fileName = result.files.single.name;

      // Upload the PDF to Supabase Storage
      await Supabase.instance.client.storage
          .from('images/articles_images')
          .uploadBinary(fileName, bytes);

      // Get the public URL for the uploaded PDF
      final String pdfUrl = Supabase.instance.client.storage
          .from('images/articles_images')
          .getPublicUrl(fileName);

      return pdfUrl;
    } catch (e) {
      print('Error selecting or uploading PDF: $e');
      return null;
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
        'parent_article_id': isSubArticle ? selectedParentArticleId : null,
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
                initialText: currentText,
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                customToolbarButtons: [
                  Wrap(
                    spacing: 8.0, // Odległość między elementami
                    runSpacing: 4.0, // Odległość między liniami
                    alignment: WrapAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _selectGallery,
                        child: Icon(Icons.add_box),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final imageUrl = await _pickAndUploadImage();
                          if (imageUrl != null) {
                            htmlEditorController.insertHtml(
                                '<img src="$imageUrl" alt="Image">');
                          }
                        },
                        child: Icon(Icons.image),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final pdfUrl = await _pickAndUploadPDF();
                          if (pdfUrl != null) {
                            htmlEditorController.insertHtml(
                              '<a href="$pdfUrl" target="_blank">Pobierz PDF</a>',
                            );
                          }
                        },
                        child: Icon(Icons.picture_as_pdf),
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
                      GestureDetector(
                        onTap: () {
                          htmlEditorController.insertHtml(
                            '<table border="1"><tr><th>Header 1</th><th>Header 2</th></tr><tr><td>Data 1</td><td>Data 2</td></tr></table>',
                          );
                        },
                        child: Icon(Icons.table_chart),
                      ),
                    ],
                  ),
                ],
                defaultToolbarButtons: [
                  FontButtons(),
                  FontSettingButtons(),
                  ColorButtons(),
                  ListButtons(),
                  ParagraphButtons(),
                  StyleButtons(),
                  // Opcjonalnie możesz dodać więcej przycisków, jeśli edytor je wspiera
                ],
                toolbarType: ToolbarType.nativeGrid,
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

  Future<String?> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    try {
      final bytes = await image.readAsBytes();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${timestamp}_${image.name}';

      // Przesyłanie pliku do Supabase Storage
      await Supabase.instance.client.storage
          .from('images/articles_images')
          .uploadBinary(fileName, bytes);

      // Pobieranie publicznego URL dla przesłanego obrazu
      final String imageUrl = Supabase.instance.client.storage
          .from('images/articles_images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
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

  Future<void> showArticleModal(
      BuildContext context,
      String title,
      List<Map<String, dynamic>> items,
      int? selectedItem,
      void Function(int?) onItemSelected) async {
    TextEditingController searchController = TextEditingController();
    String? selectedCategory;
    List<Map<String, dynamic>> filteredItems = List.from(items);

    void filterArticles(String query, String? category) {
      setState(() {
        filteredItems = items.where((article) {
          final articleTitle = article['title'].toLowerCase();
          final mainCategory =
              article['main_categories']?['name']?.toString().toLowerCase() ??
                  '';
          final searchText = query.toLowerCase();
          final categoryFilter = category?.toLowerCase() ?? '';

          bool matchesCategory =
              categoryFilter.isEmpty || mainCategory.contains(categoryFilter);

          return articleTitle.contains(searchText) && matchesCategory;
        }).toList();
      });
    }

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            searchController.addListener(() {
              setModalState(() {
                filterArticles(searchController.text, selectedCategory);
              });
            });

            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Suchen',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          hint: Text('Kategorie wählen'),
                          value: selectedCategory,
                          items: mainCategories.map((category) {
                            if (category['name'] == null)
                              return DropdownMenuItem<String>(
                                  value: null, child: Text('N/A'));

                            return DropdownMenuItem<String>(
                              value: category['name'],
                              child: Text(category['name']),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setModalState(() {
                              selectedCategory = newValue;
                              filterArticles(
                                  searchController.text, selectedCategory);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        String mainCategory = filteredItems[index]
                                ['main_categories']?['name'] ??
                            'Brak kategorii';
                        String subCategory = filteredItems[index]
                                ['subcategories_main_categories']?['name'] ??
                            'Brak podkategorii';
                        String subSubCategory = filteredItems[index]
                                    ['sub_subcategories_main_categories']
                                ?['name'] ??
                            'Brak sub-podkategorii';

                        return RadioListTile<int>(
                          title: Text(filteredItems[index]['title']),
                          subtitle: Text(
                              '$mainCategory > $subCategory > $subSubCategory'),
                          value: filteredItems[index]['id'],
                          groupValue: selectedItem,
                          onChanged: (int? value) {
                            onItemSelected(value);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
            CheckboxListTile(
              title: Text("Ist das ein Unterartikel?"),
              value: isSubArticle,
              onChanged: (bool? value) {
                setState(() {
                  isSubArticle = value ?? false;
                  if (!isSubArticle) {
                    selectedParentArticleId = null;
                    selectedParentArticleTitle = '';
                  }
                });
              },
            ),
            if (isSubArticle)
              ElevatedButton(
                onPressed: () {
                  showArticleModal(
                      context,
                      'Wählen Sie einen übergeordneten Artikel',
                      allArticles,
                      selectedParentArticleId, (int? value) {
                    setState(() {
                      selectedParentArticleId = value;
                      selectedParentArticleTitle = allArticles.firstWhere(
                          (article) => article['id'] == selectedParentArticleId,
                          orElse: () => {'title': 'N/A'})['title'];
                    });
                  });
                },
                child: Text(selectedParentArticleId == null
                    ? 'Übergeordneten Artikel wählen'
                    : selectedParentArticleTitle),
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
