import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GalleryPhotosPage extends StatelessWidget {
  final int galleryId;
  final String galleryName;

  const GalleryPhotosPage(
      {super.key, required this.galleryId, required this.galleryName});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final streamGalleryPhotos = client
        .from('articles_images')
        .stream(primaryKey: ['id'])
        .eq('gallery_id', galleryId)
        .order('created_at', ascending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Photos in $galleryName'),
      ),
      body: StreamBuilder(
        stream: streamGalleryPhotos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final photos = snapshot.data!;

          if (photos.isEmpty) {
            return Center(child: Text('No photos found in this gallery.'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final imageUrl = photo['image_url'];

              return Image.network(imageUrl, fit: BoxFit.cover);
            },
          );
        },
      ),
    );
  }
}
