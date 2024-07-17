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
      final responseAz = await client.from('articles_a_z').select('id, title');
      final responseNormal = await client.from('articles').select('id, title');

      setState(() {
        articleAzList = responseAz;
        articleNormalList = responseNormal;
      });
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
      } else {
        print('No data found for adId: $adId');
      }
    } catch (error) {
      print('Error fetching ad details: $error');
    }
  }

  Future<void> saveAd() async {
    try {
      if (selectedCompanyId == null) {
        print('Wybierz firmę przed zapisaniem reklamy');
        return;
      }

      final adData = {
        'article_az_id': selectedArticleAzId,
        'article_normal_id': selectedArticleNormalId,
        'company_id': selectedCompanyId!,
      };

      if (widget.adId == null) {
        // Add new ad
        await client.from('werbung').insert(adData);
      } else {
        // Edit existing ad
        await client.from('werbung').update(adData).eq('id', widget.adId!);
      }

      Navigator.pop(context, true);
    } catch (error) {
      print('Error saving ad: $error');
    }
  }

  Widget buildDropdown(String title, List<dynamic> items, int? selectedItem,
      void Function(int?) onChanged) {
    final dropdownItems = [
      DropdownMenuItem<int>(
        value: null,
        child: Text('keine Daten'),
      ),
      ...items.map((item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(item['title']),
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
          value: dropdownItems.any((item) => item.value == selectedItem)
              ? selectedItem
              : null,
          items: dropdownItems,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Wählen Sie einen Artikel aus',
          ),
        ),
      ],
    );
  }

  Widget buildCompanyDropdown() {
    return FutureBuilder(
      future: client.from('companies').select('id, name'),
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
            ),
            SizedBox(height: 16),
            buildDropdown(
              'Wählen Sie einen Artikel aus',
              articleNormalList,
              selectedArticleNormalId,
              (value) => setState(() => selectedArticleNormalId = value),
            ),
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
