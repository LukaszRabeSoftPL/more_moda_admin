import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddGalery2 extends StatefulWidget {
  const AddGalery2({super.key});

  @override
  State<AddGalery2> createState() => _AddGalery2State();
}

class _AddGalery2State extends State<AddGalery2> {
  SupabaseClient client = Supabase.instance.client;

  Future<void> uploadImage(File imageFile) async {
    final response = await client.storage
        .from('images') // Replace with your storage bucket name
        .upload('article_images', imageFile);

    // if (response.length == null) {
    //   print('Image uploaded successfully');
    // } else {
    //   print('Upload error: ${response.error!.message}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
