import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/pages/gallery/gallery_photo_page.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_gallery_page.dart';
import 'dart:async';

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
  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    _loadGalerries();
  }

  void _loadGalerries() async {
    try {
      final response =
          await client.from('galerries').select().order('id', ascending: true);

      // assuming response is a List<Map<String, dynamic>>
      if (response is List<Map<String, dynamic>>) {
        _streamController.add(response);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response format')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load galleries: $error')),
      );
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
          _loadGalerries();
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
    _streamController.close();
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
                  _loadGalerries();
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
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allGalleries = snapshot.data!;
                final filteredGalleries = allGalleries.where((gallery) {
                  final galleryName = gallery['name'] ?? '';
                  return galleryName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredGalleries.length,
                  itemBuilder: (context, index) {
                    final gallery = filteredGalleries[index];
                    final galleryName = gallery['name'] ?? '';
                    final galleryId = gallery['id'];
                    final galleryTitle = gallery['title'] ?? '';
                    final galleryBody = gallery['body'] ?? '';

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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text('Name:'),
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
                            //Text(galleryBody, softWrap: true, maxLines: 2),
                          ],
                        ),
                        // title: Row(
                        //   children: [
                        //     Text(galleryTitle.toUpperCase()),
                        //   ],
                        // ),
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
