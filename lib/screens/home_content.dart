import 'package:flutter/material.dart';

import 'category_products_screen.dart';
import 'product_detail_screen.dart';

class HomePageScreen extends StatelessWidget {
  HomePageScreen({super.key});
  final List<String> productNames = ["Shoes", "Watch", "Bag", "Headphones", "Jacket", "Sunglasses", "Earphones","Charger","Toy","Mobile"];
  final List<String> productPrices = ["Rs. 2,500", "Rs. 4,000", "Rs. 1,800", "Rs. 3,200", "Rs. 5,500", "Rs. 1,200","Rs. 3,200", "Rs. 2,500", "Rs. 4,000", "Rs. 1,8000"];
  final List<String> productImages = ["assets/images/shoes.png","assets/images/watch.png","assets/images/bag.png","assets/images/headphone.png","assets/images/jacket.png","assets/images/sunglasses.png","assets/images/earphone.png","assets/images/charger.png","assets/images/toy.png","assets/images/mobile.png"];
  @override
  Widget build(BuildContext context) {
    Widget categoryBox(BuildContext context , categoryName){
      return GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(categoryName: categoryName),
            ),
          );
        },
        child: Container(
          width: 100,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            categoryName,
            style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFFFD700)),
          ),
        ),
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/container.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Categories",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xFF212529)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment : MainAxisAlignment.spaceEvenly,
              children: [
                categoryBox(context,"Men"),
                categoryBox(context,"Women"),
                categoryBox(context,"Kids"),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Featured Products",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xFF212529)),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productName: productNames[index],
                          productPrice: productPrices[index],
                          productImage: productImages[index],
                        ),
                      ),
                    );
                  },
                  child: ProductCard(
                    name: productNames[index],
                    price: productPrices[index],
                    image: productImages[index],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class ProductCard extends StatelessWidget{
  final String name;
  final String price;
  final String image;
  const ProductCard({super.key, required this.name, required this.price, required this.image});
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF1A1F36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:Image.asset(
                image,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 5),
         Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 name,
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF212529)),
               ),
               const SizedBox(height: 5),
               Text(
                 price,
                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
               ),
             ],
           ),
         ),
        ],
      ),
    );
  }
}
