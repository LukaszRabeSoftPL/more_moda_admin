import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/pages/articles_normal/normal_article_add_page.dart';
import 'package:architect_schwarz_admin/views/pages/articles_normal/normal_article_edit_page.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NormalArticleListPage extends StatefulWidget {
  const NormalArticleListPage({super.key});

  @override
  State<NormalArticleListPage> createState() => _NormalArticleListPageState();
}

class _NormalArticleListPageState extends State<NormalArticleListPage> {
  SupabaseClient client = Supabase.instance.client;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int? selectedCategory;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  String getCategoryText(int category) {
    if (category == 1) {
      return 'Bauteile';
    } else if (category == 2) {
      return 'Baustoffe';
    } else if (category == 3) {
      return 'Gestaltung';
    } else if (category == 4) {
      return 'Plannung';
    } else {
      return 'Keine Kategorie';
    }
  }

  Future<void> deleteArticle(int articleId) async {
    await client.from('articles').delete().eq('id', articleId);
  }

  @override
  Widget build(BuildContext context) {
    final streamArticles = client
        .from('articles')
        .stream(primaryKey: ['id']).order('id', ascending: true);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: customButton(
              text: 'Artikel hinzufügen',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NormalArticleAddPage(),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {}); // Odśwież listę po powrocie
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Suche nach Titel',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<int>(
                  dropdownColor: Colors.white,
                  focusColor: Colors.white,
                  hint: Text('Nach Kategorie filtern'),
                  value: selectedCategory,
                  icon: Icon(Icons.filter_list),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: null, child: Text('ALLE')),
                    DropdownMenuItem(value: 1, child: Text(getCategoryText(1))),
                    DropdownMenuItem(value: 2, child: Text(getCategoryText(2))),
                    DropdownMenuItem(value: 3, child: Text(getCategoryText(3))),
                    DropdownMenuItem(value: 4, child: Text(getCategoryText(4))),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Color(0xFF6A93C3).withOpacity(0.5),
          ),
          Expanded(
            child: StreamBuilder(
              stream: streamArticles,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allArticles = snapshot.data!;
                final filteredArticles = allArticles.where((article) {
                  final articleName = article['title'] ?? '';
                  final categoryId = article['main_category_id'];
                  final matchesSearchQuery = articleName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                  final matchesCategory = selectedCategory == null ||
                      categoryId == selectedCategory;
                  return matchesSearchQuery && matchesCategory;
                }).toList();

                return ListView.builder(
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    final articleId = article['id'];
                    final articleName = article['title'] ?? '';
                    final articleBody = article['body'] ?? '';
                    final categoryName = article['main_category_id'] ??
                        0; // Upewnij się, że zwracana jest liczba całkowita, nawet jeśli nie ma danych

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      color: cardColor,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NormalArticleEditPage(
                                article: article,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              setState(() {}); // Odśwież listę po powrocie
                            }
                          });
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: buttonColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NormalArticleEditPage(
                                      article: article,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    setState(
                                        () {}); // Odśwież listę po powrocie
                                  }
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
                                      title: Row(
                                        children: [
                                          Text('Artikel löschen'),
                                        ],
                                      ),
                                      content: Text(
                                          'Sind Sie sicher, dass Sie den Artikel löschen möchten? : ${articleName}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text('NEIN'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Container(
                                            width: 50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete_forever_sharp,
                                                    color: Colors.white,
                                                    size: 20),
                                                SizedBox(
                                                    width:
                                                        5), // Add some space between the icon and the text
                                                const Text('JA'),
                                              ],
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                              backgroundColor: Colors.red),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (isConfirmed) {
                                  await deleteArticle(articleId);
                                  setState(() {}); // Odśwież listę po usunięciu
                                }
                              },
                            ),
                          ],
                        ),
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        leading: Text(
                          (index + 1).toString(),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kategorie:',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  getCategoryText(categoryName),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Text(
                              articleName.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
