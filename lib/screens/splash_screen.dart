import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>{
  @override
  void initState(){
    super.initState();
    Timer(const Duration(seconds: 3), (){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F36),
                borderRadius: BorderRadius.circular(10),
              ),
            child:Icon(Icons.shopping_cart_outlined, size: 60, color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 20),
            const Text(
              "ShopNest",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold,color:Color(0xFF1A1F36)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Wear Your Confidence",
              style: TextStyle(fontSize: 16, color: Color(0xFF1A1F36)),
            ),
          ],
        ),
      ),
    );
  }
}