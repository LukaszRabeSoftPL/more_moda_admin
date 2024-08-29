import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditAdPage extends StatefulWidget {
  final int? adId;
  final int? companyId;

  const AddEditAdPage({Key? key, this.adId, this.companyId}) : super(key: key);

  @override
  _AddEditAdPageState createState() => _AddEditAdPageState();
}

class _AddEditAdPageState extends State<AddEditAdPage> {
  SupabaseClient client = Supabase.instance.client;
  List<dynamic> articleAzList = [];
  List<dynamic> articleNormalList = [];
  int? selectedArticleAzId;
  int? selectedArticleNormalId;
  int? selectedCompanyId;

  String? categoryAz;
  String? subcategoryAz;
  String? categoryNormal;
  String? subcategoryNormal;

  @override
  void initState() {
    super.initState();
    fetchArticles();
    if (widget.companyId != null) {
      selectedCompanyId = widget.companyId;
    }
    if (widget.adId != null) {
      fetchAdDetails(widget.adId!);
    }
  }

  Future<void> fetchArticles() async {
    try {
      final responseAz = await client
          .from('articles_a_z')
          .select('id, title, main_categories!inner(name)')
          .order('title', ascending: true);

      final responseNormal = await client
          .from('articles')
          .select('id, title, main_categories!inner(name), '
              'subcategories_main_categories!inner(name), '
              'sub_subcategories_main_categories!inner(name)')
          .order('title', ascending: true);

      setState(() {
        articleAzList = responseAz;
        articleNormalList = responseNormal;
      });

      if (selectedArticleAzId != null) {
        final selectedArticleAz = articleAzList.firstWhere(
            (article) => article['id'] == selectedArticleAzId,
            orElse: () => null);
        if (selectedArticleAz != null) {
          categoryAz = selectedArticleAz['main_categories']['name'];
        }
      }

      if (selectedArticleNormalId != null) {
        final selectedArticleNormal = articleNormalList.firstWhere(
            (article) => article['id'] == selectedArticleNormalId,
            orElse: () => null);
        if (selectedArticleNormal != null) {
          categoryNormal = selectedArticleNormal['main_categories']['name'];
          subcategoryNormal =
              selectedArticleNormal['subcategories_main_categories']['name'];
        }
      }
    } catch (error) {
      print('Error fetching articles: $error');
    }
  }

  Future<void> fetchAdDetails(int adId) async {
    try {
      final response = await client
          .from('werbung')
          .select('article_az_id, article_normal_id, company_id')
          .eq('id', adId)
          .maybeSingle();

      if (response != null) {
        final data = response as Map<String, dynamic>;
        setState(() {
          selectedArticleAzId = data['article_az_id'];
          selectedArticleNormalId = data['article_normal_id'];
          selectedCompanyId = data['company_id'];
        });

        if (selectedArticleAzId != null) {
          fetchCategoryAndSubcategory('articles_a_z', selectedArticleAzId!,
              (category, subcategory, _) {
            setState(() {
              categoryAz = category;
              subcategoryAz = subcategory;
            });
          });
        }

        if (selectedArticleNormalId != null) {
          fetchCategoryAndSubcategory('articles', selectedArticleNormalId!,
              (category, subcategory, _) {
            setState(() {
              categoryNormal = category;
              subcategoryNormal = subcategory;
            });
          });
        }
      } else {
        print('Keine Daten für adId: $adId gefunden');
      }
    } catch (error) {
      print('Fehler beim Abrufen der Anzeigen-Details: $error');
    }
  }

  Future<void> fetchCategoryAndSubcategory(String table, int articleId,
      Function(String?, String?, String?) onResult) async {
    try {
      final response = await client
          .from(table)
          .select(
              'main_categories(name), subcategories_main_categories(name), sub_subcategories_main_categories(name)')
          .eq('id', articleId)
          .maybeSingle();

      if (response != null) {
        final data = response as Map<String, dynamic>;
        final category = data['main_categories']?['name'] as String?;
        final subcategory =
            data['subcategories_main_categories']?['name'] as String?;
        final subSubcategory =
            data['sub_subcategories_main_categories']?['name'] as String?;
        onResult(category, subcategory, subSubcategory);
      } else {
        onResult(null, null, null);
      }
    } catch (error) {
      print('Fehler beim Abrufen der Kategorie und Unterkategorie: $error');
      onResult(null, null, null);
    }
  }

  Future<void> saveAd() async {
    try {
      if (selectedCompanyId == null) {
        print('Wählen Sie ein Unternehmen, bevor Sie die Anzeige speichern');
        return;
      }

      final adData = {
        'article_az_id': selectedArticleAzId,
        'article_normal_id': selectedArticleNormalId,
        'company_id': selectedCompanyId!,
      };

      if (widget.adId == null) {
        // Neue Anzeige hinzufügen
        await client.from('werbung').insert(adData);
      } else {
        // Bestehende Anzeige bearbeiten
        await client.from('werbung').update(adData).eq('id', widget.adId!);
      }

      Navigator.pop(context, true);
    } catch (error) {
      print('Fehler beim Speichern der Anzeige: $error');
    }
  }

  Widget buildDropdown(String title, List<dynamic> items, int? selectedItem,
      void Function(int?) onChanged,
      {bool showOnlyCategory = false}) {
    bool isItemSelected = selectedItem != null;

    final dropdownItems = [
      DropdownMenuItem<int>(
        value: null,
        child: Text('Keine Daten'),
      ),
      ...items.map((item) {
        String category = item['main_categories']?['name'] ?? 'Keine Kategorie';
        String subcategory = item['subcategories_main_categories']?['name'] ??
            'Keine Unterkategorie';
        String subSubcategory = item['sub_subcategories_main_categories']
                ?['name'] ??
            'Keine Sub-Unterkategorie';

        return DropdownMenuItem<int>(
          value: item['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['title'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (isItemSelected || !showOnlyCategory)
                Text(
                  '$category > $subcategory > $subSubcategory',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        );
      }).toList(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<int>(
          isExpanded: true,
          value: selectedItem != null &&
                  items.any((item) => item['id'] == selectedItem)
              ? selectedItem
              : null,
          items: dropdownItems,
          onChanged: (value) {
            onChanged(value);
            if (title == 'Wählen Sie einen Artikel von A-Z aus' &&
                value != null) {
              fetchCategoryAndSubcategory('articles_a_z', value,
                  (category, subcategory, subSubcategory) {
                setState(() {
                  categoryAz = category;
                  subcategoryAz = subcategory;
                });
              });
            } else if (title == 'Wählen Sie einen Artikel aus' &&
                value != null) {
              fetchCategoryAndSubcategory('articles', value,
                  (category, subcategory, subSubcategory) {
                setState(() {
                  categoryNormal = category;
                  subcategoryNormal = subcategory;
                });
              });
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            hintText: 'Wählen Sie einen Artikel aus',
          ),
        ),
      ],
    );
  }

  Widget buildCompanyDropdown() {
    return FutureBuilder(
      future: client
          .from('companies')
          .select('id, name')
          .order('name', ascending: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text('Fehler beim Laden der Unternehmen');
        } else {
          final companies = snapshot.data as List<dynamic>;

          if (selectedCompanyId == null && companies.isNotEmpty) {
            selectedCompanyId = companies.first['id'];
          }

          return DropdownButtonFormField<int>(
            value: selectedCompanyId,
            items: companies.map((company) {
              return DropdownMenuItem<int>(
                value: company['id'],
                child: Text(company['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCompanyId = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Wählen Sie ein Unternehmen aus',
            ),
          );
        }
      },
    );
  }

  Widget buildCategoryInfo(String? category, String? subcategory) {
    if (category == null && subcategory == null) {
      return SizedBox
          .shrink(); // Zeigt nichts an, jeśli kategoria i podkategoria są puste
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != null)
          Text(
            'Kategorie: $category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        if (subcategory != null)
          Text(
            'Unterkategorie: $subcategory',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adId == null
            ? 'Fügen Sie eine Anzeige hinzu'
            : 'Bearbeiten Sie Ihre Anzeige'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveAd,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (widget.companyId == null) buildCompanyDropdown(),
            SizedBox(height: 16),
            buildDropdown(
              'Wählen Sie einen Artikel von A-Z aus',
              articleAzList,
              selectedArticleAzId,
              (value) => setState(() => selectedArticleAzId = value),
              showOnlyCategory: true, // Zeigt nur Kategorie an
            ),
            buildCategoryInfo(categoryAz, subcategoryAz),
            SizedBox(height: 16),
            buildDropdown(
              'Wählen Sie einen Artikel aus',
              articleNormalList,
              selectedArticleNormalId,
              (value) => setState(() => selectedArticleNormalId = value),
            ),
            buildCategoryInfo(categoryNormal, subcategoryNormal),
            SizedBox(height: 16),
            if (selectedCompanyId != null)
              FutureBuilder(
                future: client
                    .from('companies')
                    .select('name, image_url')
                    .eq('id', selectedCompanyId!)
                    .maybeSingle(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return Text('Fehler beim Laden der Unternehmensdaten');
                  } else {
                    final company = snapshot.data as Map<String, dynamic>;
                    return Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(company['image_url']),
                            radius: 40,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(company['name'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
