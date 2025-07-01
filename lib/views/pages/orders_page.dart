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
        .order('created_at', ascending: false)
        .execute()
        .map((event) => event.cast<Map<String, dynamic>>());
  }

  Future<String> getUserName(String userId) async {
    final response = await client
        .from('profiles')
        .select('first_name, last_name')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return 'Nieznany użytkownik';
    return '${response['first_name']} ${response['last_name']}';
  }

  Widget buildStatusIndicator(String status) {
    Color color;
    String label;

    switch (status) {
      case 'BOUGHT':
        color = Colors.green;
        label = 'Zakupione';
        break;
      case 'CURRENT':
        color = Colors.orange;
        label = 'W trakcie';
        break;
      default:
        color = Colors.grey;
        label = 'Nieznany';
    }

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: TextStyle(color: color)),
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
              final List<dynamic> boughtHistory =
                  order['bought_history'] is String
                      ? jsonDecode(order['bought_history'])
                      : order['bought_history'] ?? [];

              final DateTime createdAt = DateTime.parse(order['created_at']);
              final status = order['status'] ?? 'UNKNOWN';

              return FutureBuilder<String>(
                future: getUserName(order['owner_id']),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.data ?? 'Ładowanie...';

                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    margin: const EdgeInsets.all(8),
                    child: ExpansionTile(
                      title: Text(
                        'Benutzer: $userName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data zamówienia: ${createdAt.toLocal()}'),
                          buildStatusIndicator(status),
                        ],
                      ),
                      children: boughtHistory.map((item) {
                        final name = item['name'] ?? 'Brak nazwy';
                        final seller = item['seller_name'] ?? 'Brak sprzedawcy';
                        final category = item['category'] ?? '';
                        final subcategory = item['subcategory'] ?? '';
                        final price = item['price'] ?? 0;

                        return ListTile(
                          title: Text(name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sprzedawca: $seller'),
                              Text('Kategoria: $category / $subcategory'),
                              Text('Cena: ${price.toStringAsFixed(2)} €'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
