import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class NormalArticleEditPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const NormalArticleEditPage({Key? key, required this.article})
      : super(key: key);

  @override
  _NormalArticleEditPageState createState() => _NormalArticleEditPageState();
}

class _NormalArticleEditPageState extends State<NormalArticleEditPage> {
  late TextEditingController titleController;
  HtmlEditorController bodyController = HtmlEditorController();
  int? selectedCategory;

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
      return 'Unknown';
    }
  }

  Future<void> updateArticle() async {
    String? bodyHtml = await bodyController.getText();
    SupabaseClient client = Supabase.instance.client;
    await client.from('articles').update({
      'title': titleController.text,
      'body': bodyHtml,
      'main_category_id': selectedCategory
    }).eq('id', widget.article['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel bearbeiten'),
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
