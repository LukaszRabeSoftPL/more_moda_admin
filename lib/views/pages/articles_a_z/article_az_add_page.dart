import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  TextEditingController titleController = TextEditingController();
  HtmlEditorController bodyController = HtmlEditorController();
  int? selectedCategory;
  bool isHtmlView = false;
  int? selectedGalleryId;
  String selectedGalleryName = '';

  String getCategoryText(int category) {
    if (category == 1) {
      return 'Bauteile';
    } else if (category == 2) {
      return 'Baustoffe';
    } else if (category == 3) {
      return 'Planung';
    } else if (category == 4) {
      return 'Haustoffe';
    } else {
      return 'Unbekannt';
    }
  }

  Future<void> addArticle() async {
    try {
      String? bodyHtml = await bodyController.getText();
      SupabaseClient client = Supabase.instance.client;
      await client.from('articles_a_z').insert({
        'title': titleController.text,
        'body': bodyHtml,
        'main_category_id': selectedCategory
      });
    } catch (error) {
      // Fehlerbehandlung
      print("Fehler beim Hinzufügen des Artikels: $error");
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
      bodyController.insertHtml(
          '<popup id="$selectedGalleryId">$selectedGalleryName</popup>');
    }
  }

  void _toggleHtmlView() {
    setState(() {
      isHtmlView = !isHtmlView;
    });
    bodyController.toggleCodeView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel hinzufügen'),
        actions: [],
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
                DropdownButton<int>(
                  hint: Text('Kategorie wählen'),
                  value: selectedCategory,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: 1, child: Text(getCategoryText(1))),
                    DropdownMenuItem(value: 2, child: Text(getCategoryText(2))),
                    DropdownMenuItem(value: 3, child: Text(getCategoryText(3))),
                    DropdownMenuItem(value: 4, child: Text(getCategoryText(4))),
                  ],
                ),
              ],
            ),
            Divider(
              thickness: 1,
              color: Color(0xFF6A93C3).withOpacity(0.5),
            ),
            SizedBox(height: 50),
            Expanded(
              child: HtmlEditor(
                controller: bodyController,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Dein Text hier...',
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarType: ToolbarType.nativeScrollable,
                  customToolbarButtons: [
                    GestureDetector(
                      onTap: _selectGallery,
                      child: Icon(Icons.add_box),
                    ),
                    GestureDetector(
                      onTap: _toggleHtmlView,
                      child: Icon(isHtmlView ? Icons.code_off : Icons.code),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            customButton(
              text: 'Speichern',
              onPressed: () async {
                await addArticle();
                Navigator.pop(context, true);
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
