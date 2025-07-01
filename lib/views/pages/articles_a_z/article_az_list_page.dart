import 'package:more_moda_admin/static/static.dart';
import 'package:more_moda_admin/views/pages/articles_a_z/article_az_add_page.dart';
import 'package:more_moda_admin/views/pages/articles_a_z/article_az_edit_page.dart';
import 'package:more_moda_admin/views/widgets/add_subcategory_bauteile.dart';
import 'package:more_moda_admin/views/widgets/custom_button.dart';
import 'package:more_moda_admin/views/widgets/popup_add.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Article_AZ_ListPage extends StatefulWidget {
  const Article_AZ_ListPage({super.key});

  @override
  State<Article_AZ_ListPage> createState() => _Article_AZ_ListPageState();
}

class _Article_AZ_ListPageState extends State<Article_AZ_ListPage> {
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
      return 'Planung';
    } else if (category == 4) {
      return 'Haustoffe';
    } else {
      return 'Unknown';
    }
  }

  Future<void> deleteArticle(int articleId) async {
    await client.from('articles_a_z').delete().eq('id', articleId);
  }

  @override
  Widget build(BuildContext context) {
    final streamArticlesAZ = client
        .from('articles_a_z')
        .stream(primaryKey: ['id']).order('id', ascending: true);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: customButton(
              text: 'Artikel hinzufügen',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddArticlePage(),
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
              stream: streamArticlesAZ,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allArticlesAZ = snapshot.data!;
                final filteredArticlesAZ = allArticlesAZ.where((article) {
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
                  itemCount: filteredArticlesAZ?.length,
                  itemBuilder: (context, index) {
                    final articleAZ = filteredArticlesAZ[index];
                    final articleAZId = articleAZ['id'];
                    final articleName = articleAZ['title'] ?? '';
                    final articleBody = articleAZ['body'] ?? '';
                    final categoryName = articleAZ['main_category_id'] ?? '';

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
                              builder: (context) => EditArticlePage(
                                article: articleAZ,
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
                                    builder: (context) => EditArticlePage(
                                      article: articleAZ,
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
                                        // TextButton(
                                        //   onPressed: () {
                                        //     Navigator.pop(context, true);
                                        //   },
                                        //   child: Text('JA'),
                                        // ),
                                      ],
                                    );
                                  },
                                );
                                if (isConfirmed) {
                                  await deleteArticle(articleAZId);
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
                          // style: TextStyle(
                          //   fontWeight: FontWeight.bold,
                          //   color: Colors.red,
                          // ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kategorie:',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  getCategoryText(categoryName),
                                  style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            // Text(
                            //   articleBody,
                            //   softWrap: true,
                            //   maxLines: 3,
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: 100,
                            // )
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
