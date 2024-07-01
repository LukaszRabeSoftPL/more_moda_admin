import 'dart:typed_data';
import 'package:architect_schwarz_admin/static/static.dart';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class GalleryPhotosPage extends StatefulWidget {
  final int galleryId;
  final String galleryName;

  const GalleryPhotosPage(
      {super.key, required this.galleryId, required this.galleryName});

  @override
  _GalleryPhotosPageState createState() => _GalleryPhotosPageState();
}

class _GalleryPhotosPageState extends State<GalleryPhotosPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  String _generateFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = originalName.split('.').last;
    return '${originalName.split('.').first}_$timestamp.$extension';
  }

  bool _isLoading = false;
  void _refreshData() {
    setState(() {});
  }

  Future<void> _deleteImage(String imageUrl, String tableName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabaseClient
          .from(tableName)
          .delete()
          .eq('image_url', imageUrl)
          .eq('gallery_id', widget.galleryId);

      if (response != null && response.error == null) {
        _refreshData(); // Refresh the data to remove the deleted image.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bild erfolgreich gelöscht')),
        );
      } else if (response != null && response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Fehler beim Löschen des Bildes: ${response.error!.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bild gelöscht')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen des Bildes: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage(String bucketName, String tableName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      final String? userToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      final String apiKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpenN3YndxZmlncnVheWJsamJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ5OTg5ODksImV4cCI6MjAzMDU3NDk4OX0.BEzd2rPR2r9_eM2g1_7H-cfb-HebHZ2IlKjo6IvQRmM';

      if (userToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is not authenticated.')),
        );
        return;
      }

      for (var file in result.files) {
        final String originalFileName = file.name;
        final String fileName = _generateFileName(originalFileName);
        final Uint8List fileBytes = file.bytes!;
        final Uri uri = Uri.parse(
            'https://sizswbwqfigruaybljbk.supabase.co/storage/v1/object/${bucketName}/${fileName}');

        try {
          final http.Response response = await http.post(
            uri,
            headers: {
              'Authorization': 'Bearer $userToken',
              'apikey': apiKey,
              'Content-Type': 'application/octet-stream',
            },
            body: fileBytes,
          );

          if (response.statusCode == 200) {
            final String imageUrl =
                'https://sizswbwqfigruaybljbk.supabase.co/storage/v1/object/public/${bucketName}/${fileName}';

            final insertResponse =
                await _supabaseClient.from(tableName).insert({
              'image_url': imageUrl,
              'gallery_id': widget.galleryId,
            });

            if (insertResponse.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Bild-URL konnte nicht gespeichert werden: ${insertResponse.error!.message}')),
              );
              return;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Upload fehlgeschlagen: ${response.body}')),
            );
            return;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Fehler beim Hochladen des Bildes: $fileName')),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hochladen erfolgreich!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: Image.network(imageUrl),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final streamGalleryPhotos = _supabaseClient
        .from('articles_images')
        .stream(primaryKey: ['id'])
        .eq('gallery_id', widget.galleryId)
        .order('created_at', ascending: true);

    final streamGallerySketches = _supabaseClient
        .from('sketches_images')
        .stream(primaryKey: ['id'])
        .eq('gallery_id', widget.galleryId)
        .order('created_at', ascending: true);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gallerie:'),
            Text(
              ' ${widget.galleryName}',
              style: TextStyle(
                color: buttonColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.add),
          //   onPressed: () {
          //     _pickAndUploadImage('images/sketches_images', 'sketches_images');
          //   },
          // ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Galerie-Bilder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: buttonColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: streamGalleryPhotos,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final photos = snapshot.data!;

                      if (photos.isEmpty) {
                        return Center(
                            child: Text(
                                'In dieser Galerie wurden keine Fotos gefunden.'));
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final itemSize = constraints.maxWidth * 0.15;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 12,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: photos.length,
                            itemBuilder: (context, index) {
                              final photo = photos[index];
                              final imageUrl = photo['image_url'];

                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFullImage(imageUrl),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                  Positioned(
                                    left: 100,
                                    child: GestureDetector(
                                      onTap: () {
                                        _deleteImage(
                                            imageUrl, 'articles_images');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ]),
                                        width: 20,
                                        height: 20,
                                        child: Icon(Icons.close,
                                            color: Colors.white, size: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // IconButton(
                //   icon: Icon(Icons.add),
                //   onPressed: () {
                //     _pickAndUploadImage('images/articles_images', 'articles_images');
                //   },
                // ),
                customButton(
                  text: 'Foto hinzufügen',
                  onPressed: () {
                    _pickAndUploadImage(
                        'images/articles_images', 'articles_images');
                  },
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     _pickAndUploadImage('images/articles_images', 'articles_images');
                //   },
                //   child: Text('Foto hinzufügen'),
                // ),
                Divider(
                  color: buttonColor,
                  thickness: 1,
                ),

                //! - Sketches
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skizzen-Bilder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: buttonColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: streamGallerySketches,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final sketches = snapshot.data!;

                        if (sketches.isEmpty) {
                          return Center(
                              child:
                                  Text('No sketches found in this gallery.'));
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final itemSize = 120;

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 12,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                                childAspectRatio: 1,
                              ),
                              itemCount: sketches.length,
                              itemBuilder: (context, index) {
                                final sketch = sketches[index];
                                final imageUrl = sketch['image_url'];

                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showFullImage(imageUrl),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                                    ),
                                    Positioned(
                                      left: 100,
                                      child: GestureDetector(
                                        onTap: () {
                                          _deleteImage(
                                              imageUrl, 'sketches_images');
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                ),
                                              ]),
                                          width: 20,
                                          height: 20,
                                          child: Icon(Icons.close,
                                              color: Colors.white, size: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                    text: 'Skizzen hinzufügen',
                    onPressed: () {
                      _pickAndUploadImage(
                          'images/sketches_images', 'sketches_images');
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
