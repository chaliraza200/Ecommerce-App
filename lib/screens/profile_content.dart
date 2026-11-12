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
            color: const Color(0xFFC9A15A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF0D0D0D), size: 22),
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
        title: const Text("Profile", style: TextStyle(color: Color(0xFFC9A15A), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFC9A15A)),
            onPressed: () {
              Navigator.pushNamed(context, "/EditProfile");
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A15A)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String displayName = (data['name'] != null && (data['name'] as String).isNotEmpty)
              ? data['name']
              : "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();

          final String phone = data['phone'] ?? "-";
          final String address = data['address'] ?? "-";
          final String street = data['street'] ?? "";
          final String house = data['house'] ?? "";
          final String? profileImage = data['profileImage'];

          final String fullLocation = [house, street, address]
              .where((part) => part.isNotEmpty && part != "-")
              .join(", ");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF0D0D0D),
                  backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                      ? NetworkImage(profileImage)
                      : null,
                  child: (profileImage == null || profileImage.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Color(0xFFC9A15A))
                      : null,
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
                  decoration: const BoxDecoration(color: Color(0xFFF3EAD9)),
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
                            color: const Color(0xFFC9A15A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFF0D0D0D), size: 22),
                        ),
                        title: const Text("Edit Profile", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF0D0D0D), size: 20),
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
                            color: const Color(0xFFC9A15A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag, color: Color(0xFF0D0D0D), size: 22),
                        ),
                        title: const Text("My Orders", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF0D0D0D), size: 20),
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
                            color: const Color(0xFFC9A15A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0D0D0D), size: 22),
                        ),
                        title: const Text("Cart", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF0D0D0D), size: 20),
                        onTap: () {
                          Navigator.pushNamed(context, "/CartScreen");
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A15A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D)),
                    ),
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