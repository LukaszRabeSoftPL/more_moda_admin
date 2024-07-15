import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class NormalArticleAddPage extends StatefulWidget {
  @override
  _NormalArticleAddPageState createState() => _NormalArticleAddPageState();
}

class _NormalArticleAddPageState extends State<NormalArticleAddPage> {
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
    await client.from('articles').insert({
      'title': titleController.text,
      'body': bodyHtml,
      'main_category_id': selectedCategory
    });
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
                ),
              ),
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
