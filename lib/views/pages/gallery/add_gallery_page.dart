import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class AddPhotoPage extends StatefulWidget {
  @override
  _AddPhotoPageState createState() => _AddPhotoPageState();
}

class _AddPhotoPageState extends State<AddPhotoPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Uint8List> _images = [];
  List<String> _imageNames = [];
  List<Uint8List> _sketches = [];
  List<String> _sketchNames = [];
  TextEditingController _galleryNameController = TextEditingController();
  int? _galleryId;

  Future<void> _pickImage() async {
    if (_images.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only upload up to 6 images.')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (_images.length < 6) {
            _images.add(file.bytes!);
            _imageNames.add(file.name);
          }
        }
      });
    }
  }

  Future<void> _pickSketch() async {
    if (_sketches.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only upload up to 6 sketches.')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (_sketches.length < 6) {
            _sketches.add(file.bytes!);
            _sketchNames.add(file.name);
          }
        }
      });
    }
  }

  Future<void> _createGallery() async {
    try {
      final response = await _supabaseClient
          .from('galerries')
          .insert({'name': _galleryNameController.text})
          .select()
          .single();

      setState(() {
        _galleryId = response['id'];
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create gallery: $error')),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_galleryId == null) {
      await _createGallery();
      if (_galleryId == null) {
        return; // Stop if the gallery was not created successfully.
      }
    }

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

    for (int i = 0; i < _images.length; i++) {
      final String fileName = _imageNames[i];
      final Uint8List fileBytes = _images[i];
      final String bucketName = 'images/articles_images';
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
              await _supabaseClient.from('articles_images').insert({
            'image_url': imageUrl,
            'gallery_id': _galleryId,
          });

          if (insertResponse.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to save image URL: ${insertResponse.error!.message}')),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.body}')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('upload image: $fileName')),
        );
      }
    }

    for (int i = 0; i < _sketches.length; i++) {
      final String fileName = _sketchNames[i];
      final Uint8List fileBytes = _sketches[i];
      final String bucketName = 'images/sketches_images';
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
              await _supabaseClient.from('sketches_images').insert({
            'image_url': imageUrl,
            'gallery_id': _galleryId,
          });

          if (insertResponse.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to save sketch URL: ${insertResponse.error!.message}')),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.body}')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('upload image: $fileName')),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload successful!')),
    );

    setState(() {
      _images.clear();
      _imageNames.clear();
      _sketches.clear();
      _sketchNames.clear();
    });

    Navigator.pop(
        context, true); // Return to the previous screen and indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _galleryNameController,
              decoration: InputDecoration(labelText: 'Gallery Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Images'),
            ),
            SizedBox(height: 20),
            _images.isEmpty
                ? Text('No images selected.')
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _images.asMap().entries.map((entry) {
                      int index = entry.key;
                      Uint8List image = entry.value;
                      return Stack(
                        children: [
                          Image.memory(image,
                              width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index);
                                  _imageNames.removeAt(index);
                                });
                              },
                              child: Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickSketch,
              child: Text('Pick Sketches'),
            ),
            SizedBox(height: 20),
            _sketches.isEmpty
                ? Text('No sketches selected.')
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _sketches.asMap().entries.map((entry) {
                      int index = entry.key;
                      Uint8List sketch = entry.value;
                      return Stack(
                        children: [
                          Image.memory(sketch,
                              width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sketches.removeAt(index);
                                  _sketchNames.removeAt(index);
                                });
                              },
                              child: Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
            Spacer(),
            ElevatedButton(
              onPressed: _images.isNotEmpty || _sketches.isNotEmpty
                  ? _uploadImages
                  : null,
              child: Text('Upload Images and Sketches'),
            ),
          ],
        ),
      ),
    );
  }
}
