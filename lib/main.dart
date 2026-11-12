import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_firstapp/screens/add_product_screen.dart';
import 'package:my_firstapp/screens/admin_orders-screen.dart';
import 'package:my_firstapp/screens/admin_panel.dart';
import 'package:my_firstapp/screens/admin_product_screen.dart';
import 'package:my_firstapp/screens/cart_screen.dart';
import 'package:my_firstapp/screens/edit_profile.dart';
import 'package:my_firstapp/screens/order_screen.dart';
import 'package:my_firstapp/screens/phone_number_screen.dart';
import 'package:my_firstapp/screens/profile_content.dart';
import 'package:my_firstapp/screens/update_password.dart';

import 'firebase_auth/firebase_options.dart';

import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup _page.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Localization settings
      localizationsDelegates:
      GlobalMaterialLocalizations.delegates,

      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
      ],

      // Initial screen
      initialRoute: "/splashscreen",

      // Application routes
      routes: {
        "/splashscreen": (context) => const SplashScreen(),
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignUpScreen(),
        "/homepage": (context) => HomePage(),
        "/UpdatePassword": (context) => UpdatePassword(),
        "/OrdersScreen": (context) => OrdersScreen(),
        "/CartScreen": (context) => CartScreen(),
        "/ProfileScreen": (context) => ProfileScreen(),
        "/EditProfile": (context) => EditProfile(),
        "/PhoneScreen": (context) => PhoneNumberScreen(),
        "/AddProduct": (context) => const AddProductScreen(),
        "/adminPanel": (context) => const AdminPanel(),
        "/adminProducts": (context) => const AdminProductsScreen(),
        "/adminOrders": (context) => const AdminOrdersScreen(),
      },

      // App theme
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3EAD9),

        primarySwatch: Colors.blueGrey,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D0D0D),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          foregroundColor: Color(0xFFC9A15A),
          elevation: 0,
        ),
      ),
    );
  }
}
