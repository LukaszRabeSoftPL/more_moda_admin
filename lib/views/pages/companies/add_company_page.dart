import 'dart:typed_data';
import 'package:architect_schwarz_admin/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCompanyPage extends StatefulWidget {
  final Map<String, dynamic>? company;

  const AddCompanyPage({Key? key, this.company}) : super(key: key);

  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  final SupabaseClient client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Kontrolery tekstowe
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _homeNumberController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _wwwController = TextEditingController();
  final TextEditingController _productsController = TextEditingController();

  String? _imageUrl;
  int? _selectedMainCategoryId;
  int? _selectedSubcategoryId;
  int? _selectedSubSubcategoryId;

  List<Map<String, dynamic>> _mainCategories = [];
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _subSubcategories = [];
  List<Map<String, dynamic>> _filteredSubSubcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.company != null) {
      _nameController.text = widget.company!['name'] ?? '';
      _selectedMainCategoryId = widget.company!['main_category_id'];
      _selectedSubcategoryId = widget.company!['subcategory_id'];
      _selectedSubSubcategoryId = widget.company!['sub_subcategories_id'];
      _streetController.text = widget.company!['street'] ?? '';
      _homeNumberController.text = widget.company!['home_number'] ?? '';
      _zipCodeController.text = widget.company!['zip_code'] ?? '';
      _cityController.text = widget.company!['city'] ?? '';
      _phoneController.text = widget.company!['phone'] ?? '';
      _faxController.text = widget.company!['fax'] ?? '';
      _emailController.text = widget.company!['email'] ?? '';
      _wwwController.text = widget.company!['www'] ?? '';
      _productsController.text = widget.company!['products'] ?? '';
      _imageUrl = widget.company!['image_url'];
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final mainCategoriesResponse =
          await client.from('main_categories').select();
      final subcategoriesResponse =
          await client.from('subcategories_main_categories').select();
      final subSubcategoriesResponse =
          await client.from('sub_subcategories_main_categories').select();

      setState(() {
        _mainCategories = (mainCategoriesResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _subcategories = (subcategoriesResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _subSubcategories = (subSubcategoriesResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });

      _filterSubSubcategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch categories: $e')),
      );
    }
  }

  void _filterSubSubcategories() {
    if (_selectedSubcategoryId != null) {
      setState(() {
        _filteredSubSubcategories = _subSubcategories
            .where((subSubcategory) =>
                subSubcategory['sub_category_id'] == _selectedSubcategoryId)
            .toList();
      });
    } else {
      setState(() {
        _filteredSubSubcategories = [];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      await _uploadImage(imageBytes, pickedFile.name);
    }
  }

  Future<void> _uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final storage = Supabase.instance.client.storage;
      final fileExt = fileName.split('.').last;
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'company_images/$uniqueFileName';

      await storage.from('images').uploadBinary(filePath, imageBytes);

      final publicUrl = storage.from('images').getPublicUrl(filePath);
      setState(() {
        _imageUrl = publicUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  void _saveCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final Map<String, dynamic> _formData = {
      'name': _nameController.text,
      'main_category_id': _selectedMainCategoryId,
      'subcategory_id': _selectedSubcategoryId,
      'sub_subcategories_id': _selectedSubSubcategoryId,
      'image_url': _imageUrl,
      'street': _streetController.text,
      'home_number': _homeNumberController.text,
      'zip_code': _zipCodeController.text,
      'city': _cityController.text,
      'phone': _phoneController.text,
      'fax': _faxController.text,
      'email': _emailController.text,
      'www': _wwwController.text,
      'products': _productsController.text,
    };

    print('FormData before saving: $_formData');

    try {
      if (widget.company == null) {
        await client.from('companies').insert(_formData);
      } else {
        await client
            .from('companies')
            .update(_formData)
            .eq('id', widget.company!['id']);
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save company: $error')),
      );
    }
  }

  @override
  void dispose() {
    // Pamiętaj, aby wyczyścić kontrolery tekstowe
    _nameController.dispose();
    _streetController.dispose();
    _homeNumberController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    _emailController.dispose();
    _wwwController.dispose();
    _productsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.company == null ? 'Firma hinzufügen' : 'Firma bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                    labelText: 'Hauptkategorie', border: OutlineInputBorder()),
                value: _selectedMainCategoryId,
                items: _mainCategories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMainCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a main category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                    labelText: 'Unterkategorie', border: OutlineInputBorder()),
                value: _selectedSubcategoryId,
                items: _subcategories.map((subcategory) {
                  return DropdownMenuItem<int>(
                    value: subcategory['id'],
                    child: Text(subcategory['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategoryId = value;
                    _filterSubSubcategories();
                    _selectedSubSubcategoryId =
                        null; // Reset sub subcategory when subcategory changes
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subcategory';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                    labelText: 'Sub Unterkategorie',
                    border: OutlineInputBorder()),
                value: _selectedSubSubcategoryId,
                items: _filteredSubSubcategories.map((subSubcategory) {
                  return DropdownMenuItem<int>(
                    value: subSubcategory['id'],
                    child: Text(subSubcategory['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubSubcategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a sub subcategory';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Logo Foto'),
              ),
              if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Container(
                  child: Image.network(_imageUrl!),
                ),
              SizedBox(height: 10),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                    labelText: 'Straße', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _homeNumberController,
                decoration: const InputDecoration(
                    labelText: 'Hausnummer', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                    labelText: 'PLZ', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'Stadt', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Telefon', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _faxController,
                decoration: const InputDecoration(
                    labelText: 'Fax', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'E-Mail', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _wwwController,
                decoration: const InputDecoration(
                    labelText: 'Webseite', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _productsController,
                decoration: const InputDecoration(
                    labelText: 'Produkte (durch Komma getrennt)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              customButton(
                  text:
                      widget.company == null ? 'Firma hinzufügen' : 'Speichern',
                  onPressed: _saveCompany),
            ],
          ),
        ),
      ),
    );
  }
}
