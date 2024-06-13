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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.article['title']);
    selectedCategory = widget.article['main_category_id'];
    bodyController.setText(widget.article['body'] ?? '');
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
    await client.from('articles_a_z').update({
      'title': titleController.text,
      'body': bodyHtml,
      'main_category_id': selectedCategory
    }).eq('id', widget.article['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Article'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await updateArticle();
              Navigator.pop(context, true); // Zwraca true po zapisaniu zmian
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: HtmlEditor(
                controller: bodyController,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Your text here...',
                  initialText: widget.article['body'] ?? '',
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarType: ToolbarType.nativeScrollable,
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<int>(
              hint: Text('Select Category'),
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
      ),
    );
  }
}
