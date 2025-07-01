import 'dart:async';
import 'package:more_moda_admin/static/static.dart';
import 'package:more_moda_admin/views/widgets/custom_button.dart';
import 'package:more_moda_admin/views/widgets/is_active_circle.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_company_page.dart';

class CompaniesListPage extends StatefulWidget {
  const CompaniesListPage({super.key});

  @override
  State<CompaniesListPage> createState() => _CompaniesListPageState();
}

class _CompaniesListPageState extends State<CompaniesListPage> {
  SupabaseClient client = Supabase.instance.client;
  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    _loadCompaniesList();
  }

  void _loadCompaniesList() async {
    try {
      final response =
          await client.from('companies').select().order('id', ascending: true);

      _streamController.add(response);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unternehmen konnten nicht geladen werden: $error')),
      );
    }
  }

  Future<void> _deleteCompany(int companyId) async {
    try {
      await client.from('companies').delete().eq('id', companyId);
      _loadCompaniesList(); // Reload the list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firma erfolgreich gelöscht')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firma konnte nicht gelöscht werden: $error')),
      );
    }
  }

  Future<void> _confirmDeleteCompany(int companyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Löschung bestätigen'),
          content:
              const Text('Möchten Sie dieses Unternehmen wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('NEIN'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Container(
                width: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever_sharp,
                        color: Colors.white, size: 20),
                    SizedBox(
                        width:
                            5), // Add some space between the icon and the text
                    const Text('JA'),
                  ],
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      _deleteCompany(companyId);
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> _navigateToAddCompany() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddCompanyPage()),
    );
    if (result == true) {
      _loadCompaniesList();
    } else {
      print('Company not added');
    }
  }

  Future<void> _navigateToEditCompany(Map<String, dynamic> company) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddCompanyPage(company: company)),
    );
    if (result == true) {
      _loadCompaniesList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: customButton(
                text: 'Firma hinzufügen', onPressed: _navigateToAddCompany),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  final data = snapshot.data as List<Map<String, dynamic>>;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final company = data[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        color: cardColor,
                        child: ListTile(
                          leading: SizedBox(
                            width: 100,
                            height: 140,
                            child: Row(
                              children: [
                                // IsActiveCircle(
                                //   color: company['is_active'] == true
                                //       ? Colors.green
                                //       : Colors.red,
                                // ),
                                //SizedBox(width: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.network(
                                    company['image_url'] ?? '',
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            company['name'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            company['email'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _navigateToEditCompany(company),
                                icon: Icon(Icons.edit, color: buttonColor),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteCompany(company['id'] as int),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToEditCompany(company),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
