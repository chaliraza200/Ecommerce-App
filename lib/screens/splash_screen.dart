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
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/shopnest_appbar_icon.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "ShopNest",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFFC9A15A)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Wear Your Confidence",
              style: TextStyle(fontSize: 16, color: Color(0xFFE8DCC4)),
            ),
          ],
        ),
      ),
    );
  }
}