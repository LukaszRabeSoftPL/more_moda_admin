import 'package:architect_schwarz_admin/main.dart';
// Import the necessary package.

Future<void> createSubCategoryBauteile(String name) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .insert({'name': name, 'main_category_id': 1});
}

Future<void> updateSubCategoryBauteile(int id, String newName) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .update({'name': newName}).eq('id', id);

  // if (response.error != null) {
  //   print('Error updating category: ${response.error!.message}');
  // } else {
  //   print('Category updated successfully');
  // }
}

Future<void> updateSubCategoryBaustoffe(
    int categoryId, String updatedMainCategories) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .update({'name': updatedMainCategories}).eq('id', categoryId);
}

Future<void> deleteSubCategoryBauteile(int categoryId) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .delete()
      .eq('id', categoryId);
}

Future<void> createSubCategoryBaustoffe(String name) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .insert({'name': name, 'main_category_id': 2});
}

Future<void> deleteSubCategoryBaustoffe(int categoryId) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .delete()
      .eq('id', categoryId);
}
