import 'package:more_moda_admin/static/static.dart';
import 'package:more_moda_admin/views/pages/werbung/add_edit_werbung_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:more_moda_admin/views/widgets/custom_button.dart';
// Importujemy stronę dodawania/edytowania reklamy

class WerbungListPage extends StatefulWidget {
  const WerbungListPage({super.key});

  @override
  State<WerbungListPage> createState() => _WerbungListPageState();
}

class _WerbungListPageState extends State<WerbungListPage> {
  SupabaseClient client = Supabase.instance.client;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  Future<void> deleteAd(int adId) async {
    try {
      await client.from('werbung').delete().eq('id', adId);
    } catch (error) {
      // Obsługa błędów
      print('Error deleting ad: $error');
    }
  }

  Future<String> getCompanyName(int companyId) async {
    try {
      final response = await client
          .from('companies')
          .select('name')
          .eq('id', companyId)
          .maybeSingle();

      if (response != null) {
        final companyData = response as Map<String, dynamic>;
        return companyData['name'] ?? 'Keine Daten';
      } else {
        return 'Keine Daten';
      }
    } catch (error) {
      print('Error fetching company name: $error');
      return 'Fehler';
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamAds = client
        .from('werbung')
        .stream(primaryKey: ['id']).order('id', ascending: true);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: customButton(
              text: 'Werbung hinzufügen',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditAdPage(),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {}); // Odśwież listę po powrocie
                  }
                });
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child:
          //   // TextField(
          //   //   controller: searchController,
          //   //   decoration: InputDecoration(
          //   //     labelText: 'Suche nach Firma',
          //   //     prefixIcon: Icon(Icons.search),
          //   //     border: OutlineInputBorder(),
          //   //   ),
          //   // ),
          // ),
          Divider(
            thickness: 1,
            color: Color(0xFF6A93C3).withOpacity(0.5),
          ),
          Expanded(
            child: StreamBuilder(
              stream: streamAds,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allAds = snapshot.data ?? [];
                final filteredAds = allAds.where((ad) {
                  final companyId = ad['company_id'].toString();
                  final matchesSearchQuery = companyId
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                  return matchesSearchQuery;
                }).toList();

                if (filteredAds.isEmpty) {
                  return Center(child: Text('Keine Daten vorhanden'));
                }

                return ListView.builder(
                  itemCount: filteredAds.length,
                  itemBuilder: (context, index) {
                    final ad = filteredAds[index];
                    final adId = ad['id'];
                    final companyId = ad['company_id'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      color: cardColor,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditAdPage(
                                  adId: adId, companyId: companyId),
                            ),
                          ).then((value) {
                            if (value == true) {
                              setState(() {}); // Odśwież listę po powrocie
                            }
                          });
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: buttonColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditAdPage(
                                        adId: adId, companyId: companyId),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    setState(
                                        () {}); // Odśwież listę po powrocie
                                  }
                                });
                              },
                            ),
                            IconButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  bool isConfirmed = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Row(
                                          children: [
                                            Text('Reklama löschen'),
                                          ],
                                        ),
                                        content: Text(
                                            'Sind Sie sicher, dass Sie die Werbung löschen möchten? '),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: Text('NEIN'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Container(
                                              width: 50,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .delete_forever_sharp,
                                                      color: Colors.white,
                                                      size: 20),
                                                  SizedBox(
                                                      width:
                                                          5), // Add some space between the icon and the text
                                                  const Text('JA'),
                                                ],
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                                backgroundColor: Colors.red),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (isConfirmed) {
                                    await deleteAd(adId);
                                    setState(
                                        () {}); // Odśwież listę po usunięciu
                                  }
                                } catch (error) {
                                  print('Error deleting ad: $error');
                                }
                              },
                            ),
                          ],
                        ),
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        leading: Text(
                          (index + 1).toString(),
                        ),
                        title: FutureBuilder<String>(
                          future: getCompanyName(companyId),
                          builder: (context, companySnapshot) {
                            if (companySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Laden...');
                            } else if (companySnapshot.hasError) {
                              return Text('Fehler: ${companySnapshot.error}');
                            } else {
                              final companyName =
                                  companySnapshot.data ?? 'Keine Daten';
                              return Text(
                                companyName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
