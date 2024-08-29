import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class EditArticlePage extends StatefulWidget {
  final Map<String, dynamic> article;

  const EditArticlePage({Key? key, required this.article}) : super(key: key);

  @override
  _EditArticlePageState createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  late TextEditingController titleController;
  HtmlEditorController bodyController = HtmlEditorController();
  int? selectedCategory;
  int? selectedGalleryId;
  String selectedGalleryName = '';
  bool isHtmlView = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.article['title']);
    selectedCategory = widget.article['main_category_id'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bodyController.setText(widget.article['body'] ?? '');
    });
  }

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

  Future<void> updateArticle() async {
    String? bodyHtml = await bodyController.getText();
    SupabaseClient client = Supabase.instance.client;
    await client.from('articles_a_z').update({
      'title': titleController.text,
      'body': bodyHtml,
      'main_category_id': selectedCategory
    }).eq('id', widget.article['id']);
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
        title: Text('Artikel bearbeiten'),
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
                  hint: Text(
                    'Kategorie wählen',
                    style: TextStyle(color: Colors.grey),
                  ),
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
                  initialText: widget.article['body'] ?? '',
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
                  defaultToolbarButtons: [
                    FontButtons(),
                    ColorButtons(),
                    ListButtons(),
                    ParagraphButtons(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            customButton(
              text: 'Speichern',
              onPressed: () async {
                await updateArticle();
                Navigator.pop(context, true); // Zwraca true po zapisaniu zmian
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
  List<Map<String, dynamic>> filteredGalleries = [];
  int? selectedGalleryId;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGalleries();
    searchController.addListener(_filterGalleries);
  }

  Future<void> _loadGalleries() async {
    try {
      SupabaseClient client = Supabase.instance.client;
      final List<dynamic> response =
          await client.from('galerries').select('id, name');

      setState(() {
        galleries = response.cast<Map<String, dynamic>>();
        galleries.sort((a, b) =>
            a['name'].compareTo(b['name'])); // Sortowanie alfabetyczne
        filteredGalleries =
            galleries; // Początkowe ustawienie filtrowanej listy
      });
    } catch (error) {
      print("Fehler beim Laden der Galerien: $error");
    }
  }

  void _filterGalleries() {
    setState(() {
      filteredGalleries = galleries
          .where((gallery) => gallery['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
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
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Galerie suchen',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<int>(
              hint: Text('Galerie auswählen'),
              value: selectedGalleryId,
              onChanged: (int? newValue) {
                setState(() {
                  selectedGalleryId = newValue;
                });
              },
              items: filteredGalleries.map((gallery) {
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
