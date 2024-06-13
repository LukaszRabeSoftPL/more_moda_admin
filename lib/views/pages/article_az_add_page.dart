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

  Future<void> addArticle() async {
    String? bodyHtml = await bodyController.getText();
    SupabaseClient client = Supabase.instance.client;
    await client.from('articles_a_z').insert({
      'title': titleController.text,
      'body': bodyHtml,
      'main_category_id': selectedCategory
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Article'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await addArticle();
              Navigator.pop(context, true); // Zwraca true po dodaniu artykułu
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
