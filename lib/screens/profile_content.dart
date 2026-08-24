import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "-";

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A1F36), size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF212529), fontSize: 12)),
            Text(value, style: const TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1A1F36)),
            onPressed: () {
              Navigator.pushNamed(context, "/EditProfile");
            },
          ),
        ],
      ),
      // ── StreamBuilder listens to this user's Firestore document live ──
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Fall back to firstName+lastName if 'name' isn't set yet
          final String displayName = (data['name'] != null && (data['name'] as String).isNotEmpty)
              ? data['name']
              : "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();

          final String phone = data['phone'] ?? "-";
          final String address = data['address'] ?? "-";
          final String street = data['street'] ?? "";
          final String house = data['house'] ?? "";

          final String fullLocation = [house, street, address]
              .where((part) => part.isNotEmpty && part != "-")
              .join(", ");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1A1F36),
                  child: Icon(Icons.person, size: 50, color: Color(0xFFFFD700)),
                ),
                const SizedBox(height: 20),
                Text(
                  displayName.isEmpty ? "No Name" : displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                ),
                const SizedBox(height: 15),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow(Icons.phone, "Phone", phone.isEmpty ? "-" : phone),
                        const Divider(),
                        _infoRow(Icons.email, "Email", userEmail),
                        const Divider(),
                        _infoRow(Icons.location_on, "Location", fullLocation.isEmpty ? "-" : fullLocation),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
                  child: const Text("Account", style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFF1A1F36), size: 22),
                        ),
                        title: const Text("Edit Profile", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1A1F36), size: 20),
                        onTap: () {
                          Navigator.pushNamed(context, "/EditProfile");
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag, color: Color(0xFF1A1F36), size: 22),
                        ),
                        title: const Text("My Orders", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1A1F36), size: 20),
                        onTap: () {
                          Navigator.pushNamed(context, "/OrdersScreen");
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 60,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1F36), size: 22),
                        ),
                        title: const Text("Cart", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1A1F36), size: 20),
                        onTap: () {
                          Navigator.pushNamed(context, "/CartScreen");
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}