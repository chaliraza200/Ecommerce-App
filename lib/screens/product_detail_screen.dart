import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    this.productDescription,
  });
  final String productName;
  final String productPrice;
  final String productImage;
  final String? productDescription;

  Future<void> addToCart(Map<String, dynamic> product) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc("${uid}_${product['name']}");

    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await cartRef.set({
        'userId': uid,
        'name': product['name'],
        'price': int.parse(product['price']),
        'image': product['image'],
        'quantity': 1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFC9A15A)),
            onPressed: () {
              Navigator.pushNamed(context, "/CartScreen");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0D0D0D)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  productImage,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFC9A15A))),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 250,
                    child: Center(child: Icon(Icons.broken_image, size: 60, color: Color(0xFF0D0D0D))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(productName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
            const SizedBox(height: 10),
            Text("Rs. $productPrice", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC9A15A))),
            const SizedBox(height: 15),
            Text(
              productDescription ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A15A),
                ),
                onPressed: () {
                  Map<String, dynamic> product = {
                    'name': productName,
                    'price': productPrice,
                    'image': productImage,
                  };
                  addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$productName added to cart"),
                    ),
                  );
                },
                child: const Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}