import 'package:firebase_core/firebase_core.dart';
import 'package:my_firstapp/screens/cart_screen.dart';
import 'package:my_firstapp/screens/edit_profile.dart';
import 'package:my_firstapp/screens/order_screen.dart';
import 'package:my_firstapp/screens/profile_content.dart';
import 'firebase_auth/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:my_firstapp/screens/update_password.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup _page.dart';
import 'screens/forget_password.dart';
import 'screens/splash_screen.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     initialRoute: "/splashscreen",
     routes: {
       "/splashscreen": (context) => const SplashScreen(),
        "/login": (context) => LoginScreen(),
       "/signup": (context) => SignUpScreen(),
       "/homepage": (context) => HomePage(),
       "/ForgotPassword": (context) => ForgetPassword(),
       "/UpdatePassword": (context) => UpdatePassword(),
       "/OrdersScreen":  (context) => OrdersScreen(),
       "/CartScreen" : (context) => CartScreen(),
       "/ProfileScreen":(context)=>ProfileScreen(),
       "/EditProfile":(context)=>EditProfile(),
     },
     theme: ThemeData(
       scaffoldBackgroundColor: Color(0xFFF8F9FA),
       primarySwatch: Colors.blue,
       colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1A1F36)),
       appBarTheme: const AppBarTheme(
         foregroundColor: Color(0xFF1A1F36),
         elevation: 0,
       ),
     ),
    );
  }
}