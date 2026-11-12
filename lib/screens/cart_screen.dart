import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  int deliveryCharge = 100;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  int cleanPrice(dynamic rawPrice) {
    final digitsOnly = rawPrice.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.isEmpty ? 0 : int.parse(digitsOnly);
  }

  Future<void> increaseQuantity(String docId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(docId)
        .update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decreaseQuantity(String docId, int currentQuantity) async {
    if (currentQuantity > 1) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(docId)
          .update({'quantity': FieldValue.increment(-1)});
    } else {
      await deleteItem(docId);
    }
  }

  Future<void> deleteItem(String docId) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  Future<void> clearCart() async {
    final cartDocs = await FirebaseFirestore.instance.collection('cart').get();
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
  }
  Future<void> placeOrder(List<QueryDocumentSnapshot> cartDocs) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final items = cartDocs.map((doc) {
      return {
        'name': doc['name'],
        'price': cleanPrice(doc['price'].toString()),
        'image': doc['image'],
        'quantity': doc['quantity'],
      };
    }).toList();

    final total = getTotal(cartDocs) + deliveryCharge;

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'items': items,
      'total': total,
      'orderDate': DateTime.now(),
      'status': 'pending',
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'paymentMethod': 'Cash on Delivery',
    });

    await clearCart();
  }

  int getTotal(List<QueryDocumentSnapshot> docs) {
    int total = 0;
    for (var doc in docs) {
      final price = cleanPrice(doc['price'].toString());
      final quantity = int.parse(doc['quantity'].toString());
      total += price * quantity;
    }
    return total;
  }

  void _showSuccessDialog(int total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          '🎉 Order Placed!',
          style: TextStyle(color: Color(0xFF0D0D0D), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'order placed successfully \nTotal: PKR $total',
          style: const TextStyle(color: Color(0xFF0D0D0D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(List<QueryDocumentSnapshot> cartDocs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Checkout Details',
                style: TextStyle(
                  color: Color(0xFF0D0D0D),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Delivery Address",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A15A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.payments_outlined, color: Color(0xFF0D0D0D)),
                    SizedBox(width: 10),
                    Text(
                      "Cash on Delivery",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A15A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (_phoneController.text.trim().isEmpty ||
                            _addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter phone number and address")),
                          );
                          return;
                        }

                        final total = getTotal(cartDocs) + deliveryCharge;
                        Navigator.pop(context);
                        await placeOrder(cartDocs);
                        if (!mounted) return;
                        _showSuccessDialog(total);
                      },
                      child: const Text(
                        "Place Order",
                        style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          '🛒 My Cart',
          style: TextStyle(
            color: Color(0xFF0D0D0D),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: clearCart,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("cart")
            .where("userId",isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A15A)),
            );
          }
          final cartDocs = snapshot.data!.docs;
          if (cartDocs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Color(0xFFC9A15A)),
                  SizedBox(height: 16),
                  Text(
                    'Cart is Empty',
                    style: TextStyle(
                      color: Color(0xFF212529),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Order something!',
                    style: TextStyle(color: Color(0xFF212529)),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final item = cartDocs[index];
                    final docId = item.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['image'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC9A15A)),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Color(0xFF0D0D0D)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    color: Color(0xFF212529),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PKR ${item['price']}',
                                  style: const TextStyle(
                                    color: Color(0xFFC9A15A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => decreaseQuantity(
                                    docId, item['quantity'] as int),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Color(0xFF0D0D0D),
                                    size: 18,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(
                                    color: Color(0xFF212529),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => increaseQuantity(docId),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF0D0D0D),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Bill Summary',
                          style: TextStyle(
                            color: Color(0xFF212529),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(color: Color(0xFF212529))),
                        Text(
                          'PKR ${getTotal(cartDocs)}',
                          style: const TextStyle(color: Color(0xFFC9A15A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Charge',
                            style: TextStyle(color: Color(0xFF212529))),
                        Text(
                          'PKR $deliveryCharge',
                          style: const TextStyle(color: Color(0xFFC9A15A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFC9A15A), thickness: 1.5),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Color(0xFF212529),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'PKR ${getTotal(cartDocs) + deliveryCharge}',
                          style: const TextStyle(
                            color: Color(0xFFC9A15A),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A15A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          _showCheckoutDialog(cartDocs);
                          _showSuccessDialog;
                        },
                        child: const Text(
                          'Proceed to checkout',
                          style: TextStyle(
                            color: Color(0xFF212529),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}