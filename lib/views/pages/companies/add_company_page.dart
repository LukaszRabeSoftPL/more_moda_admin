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
  final TextEditingController _mainCategoryIdController =
      TextEditingController();
  final TextEditingController _subcategoryIdController =
      TextEditingController();
  final TextEditingController _subSubcategoriesIdController =
      TextEditingController();
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

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!['name'] ?? '';
      _mainCategoryIdController.text =
          widget.company!['main_category_id']?.toString() ?? '';
      _subcategoryIdController.text =
          widget.company!['subcategory_id']?.toString() ?? '';
      _subSubcategoriesIdController.text =
          widget.company!['sub_subcategories_id']?.toString() ?? '';
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

  int? _tryParseInt(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return int.tryParse(value);
  }

  void _saveCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final Map<String, dynamic> _formData = {
      'name': _nameController.text,
      'main_category_id': _tryParseInt(_mainCategoryIdController.text),
      'subcategory_id': _tryParseInt(_subcategoryIdController.text),
      'sub_subcategories_id': _tryParseInt(_subSubcategoriesIdController.text),
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
    _mainCategoryIdController.dispose();
    _subcategoryIdController.dispose();
    _subSubcategoriesIdController.dispose();
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
              TextFormField(
                controller: _mainCategoryIdController,
                decoration: const InputDecoration(
                    labelText: 'Main Category ID',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _subcategoryIdController,
                decoration: const InputDecoration(
                    labelText: 'Subcategory ID', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _subSubcategoriesIdController,
                decoration: const InputDecoration(
                    labelText: 'Sub Subcategories ID',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text(
                  'Logofoto',
                ),
              ),
              if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Container(
                  // width: 200,
                  // height: 200,
                  child: Image.network(
                    _imageUrl!,
                    //scale: 0.3,
                    //width: 100,
                    //  height: 100,
                    // fit: BoxFit.cover,
                  ),
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
              // ElevatedButton(
              //   onPressed: _saveCompany,
              //   child: Text(widget.company == null
              //       ? 'Firma hinzufügen'
              //       : 'Änderungen speichern'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
