import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class ProductDetailScreen extends StatelessWidget{
  const ProductDetailScreen({super.key, required this.productName, required this.productPrice,required this.productImage});
  final String productName;
  final String productPrice;
  final String productImage;
  int cleanPrice(String rawPrice) {
    final digitsOnly = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
    return int.parse(digitsOnly);
  }
  Future<void> addToCart(Map<String, dynamic> product) async {
    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(product['name']);
    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await cartRef.set({
        'name': product['name'],
        'price': cleanPrice(product['price']),
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
          icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1F36)),
          onPressed: (){
            Navigator.pushNamed(context , "/CartScreen");
          },
        ),
      ],
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF1A1F36)),
        ),
           child: ClipRRect(
             borderRadius: BorderRadius.circular(16),
             child: Image.asset(
               productImage,
               height: 250,
               fit: BoxFit.contain,
             ),
           ),
         ),
          const SizedBox(height: 20),
          Text(productName,style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color: Color(0xFF212529))),
          const SizedBox(height: 10),
          Text(productPrice,style:TextStyle(fontSize:16,fontWeight:FontWeight.bold,color:Color(0xFFFFD700))),
          const SizedBox(height: 15),
          const Text("Premium Quality , crafted for comfort and durability. A premium addition to your everyday essentials",style:TextStyle(fontSize:16,fontWeight:FontWeight.bold,color: Color(0xFF212529))),
          const SizedBox(height: 40),
          SizedBox(

            width: double.infinity,
          child:ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD700),
            ),
            onPressed: (){
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
            child: const Text("Add to Cart",style:TextStyle(fontSize:16,fontWeight:FontWeight.bold,color:Color(0xFF1A1F36))),
          ),
          ),
        ],
    ),
    ),
  );
}
}