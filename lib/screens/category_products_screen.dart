import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home_content.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget{
  final String categoryName;
  const CategoryProductsScreen ({super.key,required this.categoryName});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("products")
              .where("category" , isEqualTo: categoryName)
              .snapshots(),
          builder: (context,snapshot){
            if (snapshot.connectionState==ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
              return Center(
                child: Text("No products found in $categoryName"),
              );
            }
            final docs = snapshot.data!.docs;
            return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.61,
                ),
                itemCount: docs.length,
                itemBuilder: (context,index){
                  final data = docs[index].data() as Map<String,dynamic>;
                  final name = data["name"] ?? '';
                  final price = data["price"].toString();
                  final image = data["image"] ?? '';
                  final description = data["description"];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            productName: name,
                            productPrice: price,
                            productImage: image,
                            productDescription: description,
                          ),
                        ),
                      );
                    },
                    child: ProductCard(
                      name: name,
                      price: price,
                      image: image,
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}