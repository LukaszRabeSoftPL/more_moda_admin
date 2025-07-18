import 'package:more_moda_admin/views/widgets/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Add intl package to use DateFormat
// ignore: deprecated_member_use
import 'dart:html' as html; // tylko jeśli `kIsWeb`
import 'package:flutter/foundation.dart'; // dla kIsWeb

bool _hideEditor = false;

class NormalArticleEditPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const NormalArticleEditPage({Key? key, required this.article})
      : super(key: key);

  @override
  _NormalArticleEditPageState createState() => _NormalArticleEditPageState();
}

class _NormalArticleEditPageState extends State<NormalArticleEditPage> {
  late TextEditingController titleController;
  TextEditingController bodyController = TextEditingController();
  HtmlEditorController htmlEditorController = HtmlEditorController();
  int? selectedMainCategory;
  int? selectedSubCategory;
  int? selectedSubSubCategory;
  int? selectedGalleryId;
  String selectedGalleryName = '';
  bool isHtmlView = false;
  bool _listenerAdded = false;
  bool _isRemoving = false;
  List<Map<String, dynamic>> mainCategories = [];
  List<Map<String, dynamic>> subCategories = [];
  List<Map<String, dynamic>> subSubCategories = [];

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.article['title'] ?? '');
    bodyController.text = widget.article['body'] ?? '';

    selectedMainCategory = widget.article['main_category_id'];
    selectedSubCategory = widget.article['subcategory_id'];
    selectedSubSubCategory = widget.article['sub_subcategory_id'];

    if (selectedMainCategory != null) {
      loadMainCategories();
      loadSubCategories(selectedMainCategory!);
    }

    if (selectedSubCategory != null) {
      loadSubSubCategories(selectedSubCategory!);
    }

    // Web only - dodajemy listener tylko raz
    if (kIsWeb && !_listenerAdded) {
      _listenerAdded = true;

      html.window.onMessage.listen((event) async {
        if (_isRemoving) return;

        final data = event.data;
        if (data is Map && data['type'] == 'popupClicked') {
          final clickedText = data['value'];
          final outerHtml = data['outer'];
          final before = data['contextBefore'] ?? '';
          final after = data['contextAfter'] ?? '';

          debugPrint('[DEBUG] Otrzymano kliknięcie popup: "$clickedText"');
          debugPrint('[DEBUG] Outer HTML: $outerHtml');

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Galerie: "$clickedText"'),
              duration: Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Link entfernen',
                textColor: Colors.white,
                backgroundColor: Colors.red,
                onPressed: () async {
                  final htmlText = await htmlEditorController.getText();
                  debugPrint('[DEBUG] HTML przed usunięciem: $htmlText');

                  final contextPattern = RegExp(
                    RegExp.escape(before) +
                        RegExp.escape(outerHtml) +
                        RegExp.escape(after),
                    caseSensitive: false,
                  );

                  final updated =
                      htmlText.replaceFirstMapped(contextPattern, (match) {
                    return before + clickedText + after;
                  });

                  debugPrint('[DEBUG] HTML po usunięciu: $updated');
                  htmlEditorController.setText(updated);
                },
              ),
            ),
          );
        }
      });
    }
  }

  String _wrapWithPopupStyle(String html) {
    return '''
  <style>
    popup {
      color: blue !important;
      text-decoration: underline !important;
      cursor: pointer;
    }
  </style>
  $html
  ''';
  }

  String _removeStyleTag(String html) {
    return html
        .replaceFirst(
          RegExp(r'<style[^>]*>.*?<\/style>', dotAll: true),
          '',
        )
        .replaceFirst(
          RegExp(r'<script[^>]*>.*?<\/script>', dotAll: true),
          '',
        );
  }

  void _removeSelectedPopup() async {
    final text = await htmlEditorController.getText();
    final popupRegex =
        RegExp(r'<popup[^>]*>(.*?)<\/popup>', caseSensitive: false);
    final updated =
        text.replaceFirstMapped(popupRegex, (match) => match.group(1)!);
    htmlEditorController.setText(updated);
  }

  Future<void> showPopupLinkManager() async {
    final html = bodyController.text;

    final matches = RegExp(r'.{0,30}<popup[^>]*>(.*?)<\/popup>.{0,30}',
            caseSensitive: false)
        .allMatches(html)
        .map((m) => m.group(0) ?? '')
        .toList();

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Brak galerii do usunięcia.')));
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Wybierz galerię do usunięcia'),
        children: matches.map((fragment) {
          return SimpleDialogOption(
            child: Text(fragment.replaceAll(RegExp(r'<[^>]+>'), ''),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onPressed: () => Navigator.pop(context, fragment),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      final cleanText = selected.replaceAll(
          RegExp(r'.*<popup[^>]*>(.*?)<\/popup>.*', caseSensitive: false),
          r'$1');
      final updatedHtml = html.replaceFirst(
        RegExp(r'<popup[^>]*>(' + RegExp.escape(cleanText) + r')<\/popup>',
            caseSensitive: false),
        cleanText,
      );
      setState(() {
        bodyController.text = updatedHtml;
      });
    }
  }

  Future<String?> _pickAndUploadPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict to PDF files
      );

      if (result == null || result.files.single.bytes == null) {
        return null; // User canceled or no file selected
      }

      final bytes = result.files.single.bytes!;
      String fileName = result.files.single.name;

      // Add a unique date tag to the file name
      final String timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final List<String> nameParts = fileName.split('.');
      fileName = '${nameParts[0]}_$timestamp.${nameParts.last}';

      // Define bucket name
      final String bucketName = 'images/pdf';

      // Upload the PDF to Supabase Storage
      await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(fileName, bytes);

      // Get the public URL for the uploaded PDF
      final String pdfUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return pdfUrl;
    } catch (e) {
      print('Error selecting or uploading PDF: $e');
      return null;
    }
  }

  Future<void> loadMainCategories() async {
    try {
      final response =
          await Supabase.instance.client.from('main_categories').select();
      setState(() {
        mainCategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Fehler beim Laden der Hauptkategorien: $error');
    }
  }

  Future<void> loadSubCategories(int mainCategoryId) async {
    try {
      final response = await Supabase.instance.client
          .from('subcategories_main_categories')
          .select()
          .eq('main_category_id', mainCategoryId);
      setState(() {
        subCategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Fehler beim Laden der Unterkategorien: $error');
    }
  }

  Future<void> loadSubSubCategories(int subCategoryId) async {
    try {
      final response = await Supabase.instance.client
          .from('sub_subcategories_main_categories')
          .select()
          .eq('sub_category_id', subCategoryId);
      setState(() {
        subSubCategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Fehler beim Laden der Sub-Unterkategorien: $error');
    }
  }

  Future<void> updateArticle() async {
    try {
      String bodyHtml = bodyController.text;
      SupabaseClient client = Supabase.instance.client;
      await client.from('articles').update({
        'title': titleController.text,
        'body': bodyHtml,
        'main_category_id': selectedMainCategory,
        'subcategory_id': selectedSubCategory,
        'sub_subcategory_id': selectedSubSubCategory,
      }).eq('id', widget.article['id']);
    } catch (error) {
      print('Fehler beim Aktualisieren des Artikels: $error');
    }
  }

  Future<void> _selectGallery() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGalleryPage(),
      ),
    );
    if (result != null) {
      setState(() {
        selectedGalleryId = result['id'];
        selectedGalleryName = result['name'];
      });
      htmlEditorController.insertHtml(
          '<popup id="$selectedGalleryId">$selectedGalleryName</popup>');
    }
  }

  String _wrapWithPopupStyleAndJS(String html) {
    return '''
    <style>
      popup {
        color: blue !important;
        text-decoration: underline !important;
        cursor: pointer;
      }
    </style>
   <script>
  setTimeout(function() {
    document.querySelectorAll("popup").forEach(function(el) {
      el.style.cursor = "pointer";
      el.onclick = function(e) {
        const content = el.innerText;
        const outer = el.outerHTML;
        const parent = el.parentNode;
        const fullHtml = parent.innerHTML;
        const position = fullHtml.indexOf(outer);
        const before = fullHtml.substring(Math.max(0, position - 10), position);
        const after = fullHtml.substring(position + outer.length, position + outer.length + 10);

        console.log('[JS] popup clicked:', content);
        window.parent.postMessage({
          type: 'popupClicked',
          value: content,
          outer: outer,
          contextBefore: before,
          contextAfter: after
        }, '*');
      };
    });
  }, 500);
</script>

    $html
  ''';
  }

  Future<String?> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    try {
      final bytes = await image.readAsBytes();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${timestamp}_${image.name}';

      // Przesyłanie pliku do Supabase Storage
      await Supabase.instance.client.storage
          .from('images/articles_images')
          .uploadBinary(fileName, bytes);

      // Pobieranie publicznego URL dla przesłanego obrazu
      final String imageUrl = Supabase.instance.client.storage
          .from('images/articles_images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void showHtmlEditorDialog() async {
    String currentText = bodyController.text;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edytor',
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 800,
              height: 600,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Artikel bearbeiten',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Expanded(
                    child: HtmlEditor(
                      controller: htmlEditorController,
                      htmlEditorOptions: HtmlEditorOptions(
                        hint: 'Dein Text hier...',
                        initialText: _wrapWithPopupStyleAndJS(currentText),
                      ),
                      htmlToolbarOptions: HtmlToolbarOptions(
                        customToolbarButtons: [
                          GestureDetector(
                            onTap: _selectGallery,
                            child: Icon(Icons.add_box),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final imageUrl = await _pickAndUploadImage();
                              if (imageUrl != null) {
                                htmlEditorController.insertHtml(
                                    '<img src="$imageUrl" alt="Image">');
                              }
                            },
                            child: Icon(Icons.image),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final pdfUrl = await _pickAndUploadPDF();
                              if (pdfUrl != null) {
                                htmlEditorController.insertHtml(
                                  '<a href="$pdfUrl" target="_blank">PDF herunterladen</a>',
                                );
                              }
                            },
                            child: Icon(Icons.picture_as_pdf),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isHtmlView = !isHtmlView;
                              });
                              htmlEditorController.toggleCodeView();
                            },
                            child:
                                Icon(isHtmlView ? Icons.code_off : Icons.code),
                          ),
                          GestureDetector(
                            onTap: _removeSelectedPopup,
                            child: Icon(Icons.link_off),
                          ),
                          GestureDetector(
                            onTap: () {
                              htmlEditorController.insertHtml(
                                '<table border="1"><tr><th>Header 1</th><th>Header 2</th></tr><tr><td>Data 1</td><td>Data 2</td></tr></table>',
                              );
                            },
                            child: Icon(Icons.table_chart),
                          ),
                        ],
                        defaultToolbarButtons: [
                          FontButtons(),
                          FontSettingButtons(),
                          ColorButtons(),
                          ListButtons(),
                          ParagraphButtons(),
                          StyleButtons(),
                        ],
                        toolbarType: ToolbarType.nativeGrid,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          String? editedText =
                              await htmlEditorController.getText();
                          String cleanedText =
                              _removeStyleTag(editedText ?? '');
                          setState(() {
                            bodyController.text = cleanedText;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text('Speichern'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showCategoryModal(
      BuildContext context,
      String title,
      List<Map<String, dynamic>> items,
      int? selectedItem,
      void Function(int?) onItemSelected) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile<int>(
                title: Text(items[index]['name']),
                value: items[index]['id'],
                groupValue: selectedItem,
                onChanged: (int? value) {
                  onItemSelected(value);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    showCategoryModal(
                      context,
                      'Kategorie wählen',
                      mainCategories,
                      selectedMainCategory,
                      (int? value) {
                        setState(() {
                          selectedMainCategory = value;
                          loadSubCategories(value!);
                        });
                      },
                    );
                  },
                  child: Text(selectedMainCategory == null
                      ? 'Kategorie wählen'
                      : mainCategories.firstWhere(
                          (category) => category['id'] == selectedMainCategory,
                          orElse: () => {'name': 'N/A'},
                        )['name']),
                ),
              ],
            ),
            if (selectedMainCategory != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showCategoryModal(
                          context,
                          'Unterkategorie wählen',
                          subCategories,
                          selectedSubCategory,
                          (int? value) {
                            setState(() {
                              selectedSubCategory = value;
                              loadSubSubCategories(value!);
                            });
                          },
                        );
                      },
                      child: Text(selectedSubCategory == null
                          ? 'Unterkategorie wählen'
                          : subCategories.isNotEmpty
                              ? subCategories.firstWhere(
                                  (category) =>
                                      category['id'] == selectedSubCategory,
                                  orElse: () => {'name': 'N/A'},
                                )['name']
                              : 'Unterkategorie wählen'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showCategoryModal(
                          context,
                          'Sub-Unterkategorie wählen',
                          subSubCategories,
                          selectedSubSubCategory,
                          (int? value) {
                            setState(() {
                              selectedSubSubCategory = value;
                            });
                          },
                        );
                      },
                      child: Text(selectedSubSubCategory == null
                          ? 'Sub-Unterkategorie wählen'
                          : subSubCategories.isNotEmpty
                              ? subSubCategories.firstWhere(
                                  (category) =>
                                      category['id'] == selectedSubSubCategory,
                                  orElse: () => {'name': 'N/A'},
                                )['name']
                              : 'Sub-Unterkategorie wählen'),
                    ),
                  ),
                ],
              ),
            Divider(
              thickness: 1,
              color: Color(0xFF6A93C3).withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: HtmlEditor(
                controller: htmlEditorController,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Dein Text hier...',
                  initialText: _wrapWithPopupStyleAndJS(bodyController.text),
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  customToolbarButtons: [
                    GestureDetector(
                      onTap: _selectGallery,
                      child: Icon(Icons.add_box),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final imageUrl = await _pickAndUploadImage();
                        if (imageUrl != null) {
                          htmlEditorController
                              .insertHtml('<img src="$imageUrl" alt="Image">');
                        }
                      },
                      child: Icon(Icons.image),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final pdfUrl = await _pickAndUploadPDF();
                        if (pdfUrl != null) {
                          htmlEditorController.insertHtml(
                            '<a href="$pdfUrl" target="_blank">PDF herunterladen</a>',
                          );
                        }
                      },
                      child: Icon(Icons.picture_as_pdf),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isHtmlView = !isHtmlView;
                        });
                        htmlEditorController.toggleCodeView();
                      },
                      child: Icon(isHtmlView ? Icons.code_off : Icons.code),
                    ),
                    GestureDetector(
                      onTap: _removeSelectedPopup,
                      child: Icon(Icons.link_off),
                    ),
                    GestureDetector(
                      onTap: () {
                        htmlEditorController.insertHtml(
                          '<table border="1"><tr><th>Header 1</th><th>Header 2</th></tr><tr><td>Data 1</td><td>Data 2</td></tr></table>',
                        );
                      },
                      child: Icon(Icons.table_chart),
                    ),
                  ],
                  defaultToolbarButtons: [
                    FontButtons(),
                    FontSettingButtons(),
                    ColorButtons(),
                    ListButtons(),
                    ParagraphButtons(),
                    StyleButtons(),
                  ],
                  toolbarType: ToolbarType.nativeGrid,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButton(
                  text: 'Speichern',
                  onPressed: () async {
                    String? editedText = await htmlEditorController.getText();
                    String cleanedText = _removeStyleTag(editedText ?? '');
                    setState(() {
                      bodyController.text = cleanedText;
                    });
                    await updateArticle();
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SelectGalleryPage extends StatefulWidget {
  @override
  _SelectGalleryPageState createState() => _SelectGalleryPageState();
}

class _SelectGalleryPageState extends State<SelectGalleryPage> {
  List<Map<String, dynamic>> galleries = [];
  List<Map<String, dynamic>> filteredGalleries = [];
  int? selectedGalleryId;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGalleries();

    searchController.addListener(_filterGalleries);
  }

  Future<void> _loadGalleries() async {
    try {
      SupabaseClient client = Supabase.instance.client;
      final List<dynamic> response =
          await client.from('galerries').select('id, name');

      setState(() {
        galleries = response.cast<Map<String, dynamic>>();
        galleries.sort((a, b) =>
            a['name'].compareTo(b['name'])); // Sortowanie alfabetyczne
        filteredGalleries =
            galleries; // Początkowe ustawienie filtrowanej listy
      });
    } catch (error) {
      print("Fehler beim Laden der Galerien: $error");
    }
  }

  void _filterGalleries() {
    setState(() {
      filteredGalleries = galleries
          .where((gallery) => gallery['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galerie auswählen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Galerie suchen',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<int>(
              hint: Text('Galerie auswählen'),
              value: selectedGalleryId,
              onChanged: (int? newValue) {
                setState(() {
                  selectedGalleryId = newValue;
                });
              },
              items: filteredGalleries.map((gallery) {
                return DropdownMenuItem<int>(
                  value: gallery['id'],
                  child: Text(gallery['name']),
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Abbrechen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    if (selectedGalleryId != null) {
                      Navigator.of(context).pop({
                        'id': selectedGalleryId,
                        'name': galleries.firstWhere((gallery) =>
                            gallery['id'] == selectedGalleryId)['name']
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
