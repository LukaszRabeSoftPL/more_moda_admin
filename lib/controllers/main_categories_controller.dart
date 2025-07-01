import 'package:more_moda_admin/main.dart';
// Import the necessary package.

Future<void> createMainCategories(String name) async {
  await supabaseClient.from('main_categories').insert({'name': name});
}

Future<void> updateMainCategories(
    String categoryId, String updatedMainCategories) async {
  await supabaseClient
      .from('main_categories')
      .update({'name': updatedMainCategories}).eq('id', categoryId);
}

Future<void> deleteMainCategories(int categoryId) async {
  await supabaseClient.from('main_categories').delete().eq('id', categoryId);
}
