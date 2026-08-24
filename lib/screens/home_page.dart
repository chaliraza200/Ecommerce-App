import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_firstapp/screens/profile_content.dart';
import 'home_content.dart';
import 'order_screen.dart';
class HomePage extends StatefulWidget{
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageScreen();
}
class _HomePageScreen extends State<HomePage>{
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePageScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context){
    return Scaffold(
       drawer: Drawer(
         child: ListView(
           children: [
             StreamBuilder<DocumentSnapshot>(
               stream: FirebaseFirestore.instance
                   .collection("users")
                   .doc(FirebaseAuth.instance.currentUser!.uid)
                   .snapshots(),
               builder: (context, snapshot) {
                 String name = "Loading...";
                 if(snapshot.hasData && snapshot.data!.exists){
                   final data = snapshot.data!.data() as Map<String, dynamic>;
                   name = (data["name"] != null && (data["name"] as String).isNotEmpty)
                   ? data["name"]
                       : "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();
                 }
                 return UserAccountsDrawerHeader(
                   decoration: const BoxDecoration(color: Color(0xFF1A1F36)),
                   accountName: Text(name),
                   accountEmail: Text(FirebaseAuth.instance.currentUser?.email ??""),
                   currentAccountPicture: const CircleAvatar(
                     backgroundColor: Color(0xFFFFD700),
                     child:Icon(Icons.person,color: Color(0xFF1A1F36),size: 50),
                   ),
                 );
               },
             ),
             ListTile(
               leading: Icon(Icons.home, color: Color(0xFF1A1F36)),
               title: Text("Home",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
               onTap : (){
                 setState(() {
                   _selectedIndex = 0;
                 });
                 Navigator.pop(context);
               },
             ),
             ListTile(
               leading: Icon(Icons.assignment, color: Color(0xFF1A1F36)),
               title: Text("Orders",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
               onTap: () {
                 setState((){
                   _selectedIndex = 1;
                 });
                 Navigator.pop(context);
               },
             ),
             ListTile(
               leading: Icon(Icons.shopping_cart_outlined , color: Color(0xFF1A1F36)),
               title: Text("Cart",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
               onTap: () {
                 setState((){
                   Navigator.pushNamed(context , "/CartScreen");
                 });
               },
             ),
             ListTile(
               leading: Icon(Icons.person, color: Color(0xFF1A1F36)),
               title: Text("Profile",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
               onTap: (){
                  setState((){
                    _selectedIndex = 2;
                  });
                  Navigator.pop(context);
               },
             ),
             Divider(
               color: Color(0xFF1A1F36),
               thickness: 3,
             ),
             ListTile(
               leading: Icon(Icons.logout , color: Color(0xFF1A1F36)),
               title: Text("Logout",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
               onTap: (){
                 Navigator.pushNamed(context, "/login");
               },
             ),
           ],
         ),
      ),
      appBar: AppBar(
        title: const Text(
          "ShopNest",
          style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold,color: Color(0xFF1A1F36)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF1A1F36)),
            onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Feature Coming Soon"),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1F36)),
            onPressed: (){
              Navigator.pushNamed(context, "/CartScreen");
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFFD700),
        unselectedItemColor: Color(0xFF1A1F36),
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
