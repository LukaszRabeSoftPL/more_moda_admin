import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:more_moda_admin/static/static.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final SupabaseClient client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    return client
        .from('carts')
        .stream(primaryKey: ['id'])
        .eq('status', 'BOUGHT')
        .order('created_at', ascending: false)
        .execute()
        .map((event) => event.cast<Map<String, dynamic>>());
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select(
            'first_name, last_name, nick_name, email, street_name, house_number, postal_code, city, country, phone_number')
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getSellerProfile(String sellerName) async {
    final response = await client
        .from('profiles')
        .select(
            'first_name, last_name, nick_name, email, street_name, house_number, postal_code, city, country, phone_number')
        .eq('nick_name', sellerName)
        .maybeSingle();

    return response;
  }

  Widget buildProfileInfo(Map<String, dynamic> user, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText('$title:',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SelectableText(
            'Name: ${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
        SelectableText('Nickname: ${user['nick_name'] ?? ''}'),
        SelectableText('E-Mail: ${user['email'] ?? ''}'),
        SelectableText('Telefon: ${user['phone_number'] ?? ''}'),
        SelectableText(
            'Adresse: ${user['street_name'] ?? ''} ${user['house_number'] ?? ''}'),
        SelectableText(
            'PLZ / Ort: ${user['postal_code'] ?? ''} ${user['city'] ?? ''}'),
        SelectableText('Land: ${user['country'] ?? ''}'),
      ],
    );
  }

  Widget buildStatusIndicator() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 6),
          decoration:
              BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        ),
        const Text('Gekauft', style: TextStyle(color: Colors.green)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getOrdersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final createdAt = DateTime.parse(order['created_at']);
              final formattedDate =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

              final List<dynamic> boughtHistory =
                  order['bought_history'] is String
                      ? jsonDecode(order['bought_history'])
                      : order['bought_history'] ?? [];

              final sellerName = boughtHistory.isNotEmpty
                  ? (boughtHistory.first['seller_name'] ?? 'Kein Verkäufer')
                  : 'Kein Verkäufer';

              return FutureBuilder<Map<String, dynamic>?>(
                future: getUserProfile(order['owner_id']),
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data;

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: getSellerProfile(sellerName),
                    builder: (context, sellerSnapshot) {
                      final seller = sellerSnapshot.data;

                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          leading: const Icon(Icons.shopping_cart_outlined),
                          title: SelectableText(
                            'Bestellung von: $sellerName'
                            '${seller != null ? ' (${seller['first_name'] ?? ''} ${seller['last_name'] ?? ''})' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText('Bestelldatum: $formattedDate'),
                              buildStatusIndicator(),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// LEWA — Verkäuferdaten
                                      Expanded(
                                        flex: 1,
                                        child: Card(
                                          margin: const EdgeInsets.all(4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: seller != null
                                                ? buildProfileInfo(
                                                    seller, 'Verkäuferdaten')
                                                : const SelectableText(
                                                    'Lädt Verkäuferdaten...'),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      /// PRAWA — Käuferdaten
                                      Expanded(
                                        flex: 1,
                                        child: Card(
                                          margin: const EdgeInsets.all(4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: user != null
                                                ? buildProfileInfo(
                                                    user, 'Käuferdaten')
                                                : const SelectableText(
                                                    'Lädt Käuferdaten...'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  /// DÓŁ — Produkty
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: boughtHistory.map((item) {
                                      final name = item['name'] ?? 'Kein Name';
                                      final sellerItem = item['seller_name'] ??
                                          'Kein Verkäufer';
                                      final category = item['category'] ?? '';
                                      final subcategory =
                                          item['subcategory'] ?? '';
                                      final price = item['price'] ?? 0;

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: ListTile(
                                          title: SelectableText(
                                            'Artikel: $name',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SelectableText(
                                                  'Verkäufer: $sellerItem'),
                                              SelectableText(
                                                  'Kategorie: $category / $subcategory'),
                                              SelectableText(
                                                  'Preis: ${price.toStringAsFixed(2)} €'),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
