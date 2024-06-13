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

  Future<void> _uploadImages() async {
    final String? userToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    if (userToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated.')),
      );
      return;
    }

    for (int i = 0; i < _images.length; i++) {
      final String fileName = _imageNames[i];
      final Uint8List fileBytes = _images[i];
      final String bucketName = 'images/article_images';
      final Uri uri = Uri.parse(
          'https://sizswbwqfigruaybljbk.supabase.co/storage/v1/object/${bucketName}/${fileName}');

      final http.Response response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $userToken',
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpenN3YndxZmlncnVheWJsamJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ5OTg5ODksImV4cCI6MjAzMDU3NDk4OX0.BEzd2rPR2r9_eM2g1_7H-cfb-HebHZ2IlKjo6IvQRmM',
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.body}')),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload successful!')),
    );

    setState(() {
      _images.clear();
      _imageNames.clear();
    });
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
            Spacer(),
            ElevatedButton(
              onPressed: _images.isNotEmpty ? _uploadImages : null,
              child: Text('Upload Images'),
            ),
          ],
        ),
      ),
    );
  }
}
