import 'package:architect_schwarz_admin/views/pages/gallery/gallery_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_gallery_page.dart'; // Import the new AddGalleryPage
// Import the GalleryPhotosPage

class GalerryListPage extends StatefulWidget {
  const GalerryListPage({super.key});

  @override
  State<GalerryListPage> createState() => _GalerryListPageState();
}

class _GalerryListPageState extends State<GalerryListPage> {
  SupabaseClient client = Supabase.instance.client;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int? selectedCategory;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final streamGalerries = client
        .from('galerries')
        .stream(primaryKey: ['id']).order('id', ascending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGalleryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: streamGalerries,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allArticlesAZ = snapshot.data!;
          final filteredArticlesAZ = allArticlesAZ.where((article) {
            final articleName = article['title'] ?? '';
            final categoryId = article['main_category_id'];
            final matchesSearchQuery =
                articleName.toLowerCase().contains(searchQuery.toLowerCase());
            final matchesCategory =
                selectedCategory == null || categoryId == selectedCategory;
            return matchesSearchQuery && matchesCategory;
          }).toList();

          return ListView.builder(
            itemCount: filteredArticlesAZ.length,
            itemBuilder: (context, index) {
              final articleAZ = filteredArticlesAZ[index];
              final galeryName = articleAZ['name'] ?? '';
              final articleAZId = articleAZ['id'];
              final articleName = articleAZ['title'] ?? '';
              final articleBody = articleAZ['body'] ?? '';
              final categoryName = articleAZ['main_category_id'] ?? '';

              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryPhotosPage(
                          galleryId: articleAZId,
                          galleryName: galeryName,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => EditArticlePage(
                          //       article: articleAZ,
                          //     ),
                          //   ),
                          // ).then((value) {
                          //   if (value == true) {
                          //     setState(() {}); // Odśwież listę po powrocie
                          //   }
                          // });
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
                                title: Text('Delete article'),
                                content: Text(
                                    'Are you sure you want to delete the article ${articleName}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text('NO'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text('YES'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (isConfirmed) {
                            // await deleteArticle(articleAZId);
                            setState(() {}); // Odśwież listę po usunięciu
                          }
                        },
                      ),
                    ],
                  ),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -4),
                  leading: Text((index + 1).toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Name:'),
                          Text(galeryName),
                        ],
                      ),
                      Text(articleBody, softWrap: true, maxLines: 2),
                    ],
                  ),
                  title: Row(
                    children: [
                      Text(articleName.toUpperCase()),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
