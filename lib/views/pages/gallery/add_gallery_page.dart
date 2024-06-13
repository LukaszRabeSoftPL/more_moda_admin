import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html; // Dodaj import dla platformy web

class AddGalleryPage extends StatefulWidget {
  const AddGalleryPage({super.key});

  @override
  State<AddGalleryPage> createState() => _AddGalleryPageState();
}

class _AddGalleryPageState extends State<AddGalleryPage> {
  SupabaseClient client = Supabase.instance.client;
  TextEditingController nameController = TextEditingController();
  List<XFile>? _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length + _imageFiles!.length <= 6) {
      setState(() {
        _imageFiles!.addAll(pickedFiles);
      });
    }
  }

  Future<void> _addGallery() async {
    final name = nameController.text;

    if (name.isEmpty || _imageFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and at least one image are required')),
      );
      return;
    }

    // Create gallery
    final response =
        await client.from('gallery').insert({'name': name}).select().single();
    final galleryId = response['id'];

    // Upload images
    for (var file in _imageFiles!) {
      final bytes = await file.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await client.storage
          .from('images') // Use your actual bucket name
          .uploadBinary('article_images/$fileName', bytes);

      final imageUrl = client.storage
          .from('images')
          .getPublicUrl('article_images/$fileName');

      // Insert image record
      await client.from('articles_images').insert({
        'image_url': imageUrl,
        'gallery_id': galleryId,
      });
    }

    Navigator.pop(context);
  }

  Widget _buildImagePreview(XFile file) {
    return FutureBuilder<String>(
      future: file.readAsBytes().then(
          (bytes) => html.Url.createObjectUrlFromBlob(html.Blob([bytes]))),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final url = snapshot.data!;
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(
                  url, // Display picked image for web
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _imageFiles!.remove(file);
                    });
                  },
                )
              ],
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Gallery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Gallery Name'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _imageFiles!.map((file) => _buildImagePreview(file)).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.add_a_photo),
              label: Text('Pick Images'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addGallery,
              child: Text('Add Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
