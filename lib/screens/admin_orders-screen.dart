import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> markAsDelivered(String docId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(docId)
        .update({'status': 'delivered'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A15A))),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFC9A15A),
          indicatorColor: const Color(0xFFC9A15A),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildOrderList('pending'),
          buildOrderList('delivered'),
        ],
      ),
    );
  }

  Widget buildOrderList(String status) {
    return StreamBuilder<QuerySnapshot>(
      // Koi userId filter nahi — admin ko SAB users ke orders dikhne hain
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A15A)));
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return Center(
            child: Text(
              status == 'pending' ? 'Koi pending order nahi' : 'Koi delivered order nahi',
              style: const TextStyle(color: Color(0xFF212529), fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;
            final items = data['items'] as List;
            final total = data['total'];
            final docId = order.id;
            final phone = data['phone'] ?? '-';
            final address = data['address'] ?? '-';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${docId.substring(0, 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Color(0xFFC9A15A)),
                      const SizedBox(width: 4),
                      Text(phone, style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFFC9A15A)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(address, style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item['name']} x${item['quantity']}',
                      style: const TextStyle(color: Color(0xFF555555)),
                    ),
                  )),

                  const SizedBox(height: 8),
                  Text(
                    'Total: PKR $total',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A15A)),
                  ),

                  if (status == 'pending') ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => markAsDelivered(docId),
                        child: const Text('Mark as Delivered'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}