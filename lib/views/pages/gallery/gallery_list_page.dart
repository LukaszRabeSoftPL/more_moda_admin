import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/gallery_photo_page.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_gallery_page.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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

  static const _pageSize = 13000;

  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _loadGalerries(pageKey);
    });
  }

  Future<void> _loadGalerries(int pageKey) async {
    try {
      // Pobranie danych z tabeli 'galerries'
      final response = await client
          .from('galerries')
          .select()
          .order('id', ascending: true)
          .range(pageKey, pageKey + _pageSize - 1);

      // Konwersja odpowiedzi do listy (zakładając, że response jest typu dynamic lub podobnego)
      final List<Map<String, dynamic>> allItems =
          List<Map<String, dynamic>>.from(response);

      // Filtrowanie wyników na podstawie zapytania wyszukiwania
      final filteredItems = allItems.where((gallery) {
        // Konwersja nazwy galerii na małe litery oraz usunięcie białych znaków
        final galleryName =
            gallery['name']?.toString().toLowerCase().trim() ?? '';
        // Konwersja zapytania wyszukiwania na małe litery oraz usunięcie białych znaków
        final searchQueryLower = searchQuery.toLowerCase().trim();
        // Sprawdzenie, czy nazwa galerii zawiera zapytanie wyszukiwania
        return galleryName.contains(searchQueryLower);
      }).toList();

      final isLastPage = filteredItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(filteredItems);
      } else {
        final nextPageKey = pageKey + filteredItems.length;
        _pagingController.appendPage(filteredItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _deleteGallery(int galleryId, String galleryName) async {
    bool isConfirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Galerie löschen'),
          content:
              Text('Möchten Sie die Galerie wirklich löschen: $galleryName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('NEIN'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Container(
                width: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever_sharp,
                        color: Colors.white, size: 20),
                    SizedBox(
                        width:
                            5), // Add some space between the icon and the text
                    const Text('JA'),
                  ],
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );

    if (isConfirmed) {
      try {
        final response =
            await client.from('galerries').delete().eq('id', galleryId);

        if (response.error == null) {
          _pagingController.refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gallery deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to delete gallery: ${response.error!.message}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting gallery: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: customButton(
              text: 'Galerie hinzufügen',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPhotoPage(),
                  ),
                );

                if (result == true) {
                  _pagingController.refresh();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Suchen',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _pagingController.refresh();
              },
            ),
          ),
          Expanded(
            child: PagedListView<int, Map<String, dynamic>>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
                itemBuilder: (context, gallery, index) {
                  final galleryName = gallery['name'] ?? '';
                  final galleryId = gallery['id'];

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
                            builder: (context) => GalleryPhotosPage(
                              galleryId: galleryId,
                              galleryName: galleryName,
                            ),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: buttonColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GalleryPhotosPage(
                                    galleryId: galleryId,
                                    galleryName: galleryName,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteGallery(galleryId, galleryName);
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
                              SizedBox(width: 10),
                              Text(
                                galleryName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
