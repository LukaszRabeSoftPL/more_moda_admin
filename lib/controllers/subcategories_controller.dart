import 'package:architect_schwarz_admin/main.dart';
// Import the necessary package.

//BAUTAILE CRUD
Future<void> deleteSubCategoryBauteile(int categoryId) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .delete()
      .eq('id', categoryId);
}

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

//BAUSTOFE CRUD

Future<void> updateSubCategoryBaustoffe(
    int categoryId, String updatedMainCategories) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .update({'name': updatedMainCategories}).eq('id', categoryId);
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

//GESTALTUNG CRUD
Future<void> updateSubCategoryGestaltung(
    int categoryId, String updatedMainCategories) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .update({'name': updatedMainCategories}).eq('id', categoryId);
}

Future<void> createSubCategoryGestaltung(String name) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .insert({'name': name, 'main_category_id': 3});
}

Future<void> deleteSubCategoryGestaltung(int categoryId) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .delete()
      .eq('id', categoryId);
}

//PLANNUNG CRUD
Future<void> updateSubCategoryPlannung(
    int categoryId, String updatedMainCategories) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .update({'name': updatedMainCategories}).eq('id', categoryId);
}

Future<void> createSubCategoryPlannung(String name) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .insert({'name': name, 'main_category_id': 4});
}

Future<void> deleteSubCategoryPlannung(int categoryId) async {
  await supabaseClient
      .from('subcategories_main_categories')
      .delete()
      .eq('id', categoryId);
}
