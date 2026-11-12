import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_firstapp/screens/profile_content.dart';
import 'package:my_firstapp/screens/search_screen.dart';
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
                String? profileImage;
                if(snapshot.hasData && snapshot.data!.exists){
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = (data["name"] != null && (data["name"] as String).isNotEmpty)
                      ? data["name"]
                      : "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();
                  profileImage = data["profileImage"];
                }
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF0D0D0D)),
                  accountName: Text(name),
                  accountEmail: Text(FirebaseAuth.instance.currentUser?.email ??""),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: const Color(0xFFC9A15A),
                    backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                        ? NetworkImage(profileImage)
                        : null,
                    child: (profileImage == null || profileImage.isEmpty)
                        ? const Icon(Icons.person, color: Color(0xFF0D0D0D), size: 50)
                        : null,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF0D0D0D)),
              title: Text("Home",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
              onTap : (){
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Color(0xFF0D0D0D)),
              title: Text("Orders",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
              onTap: () {
                setState((){
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart_outlined , color: Color(0xFF0D0D0D)),
              title: Text("Cart",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
              onTap: () {
                setState((){
                  Navigator.pushNamed(context , "/CartScreen");
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF0D0D0D)),
              title: Text("Profile",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
              onTap: (){
                setState((){
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            Divider(
              color: Color(0xFF0D0D0D),
              thickness: 3,
            ),
            ListTile(
              leading: Icon(Icons.logout , color: Color(0xFF0D0D0D)),
              title: Text("Logout",style: TextStyle(color: Color(0xFF212529),fontWeight: FontWeight.bold)),
              onTap: (){
                Navigator.pushNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/shopnest_appbar_icon.png', height: 30),
            const SizedBox(width: 8),
            const Text(
              "ShopNest",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC9A15A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFFC9A15A)),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFFC9A15A)),
            onPressed: (){
              Navigator.pushNamed(context, "/CartScreen");
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFC9A15A),
        unselectedItemColor: Color(0xFF0D0D0D),
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