import 'dart:io'; //
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase_auth/auth_service.dart';

class EditProfile extends StatefulWidget{
  const EditProfile({super.key});
  @override
  State<EditProfile> createState() => _EditProfileState();
}
class _EditProfileState extends State<EditProfile>{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final AuthService _authService = AuthService();
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _streetController.text = data['street'] ?? '';
        _houseController.text = data['house'] ?? '';
        _existingImageUrl = data['profileImage'];
      });
    }
  }
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
    Navigator.pop(context);
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFC9A15A), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('Profile Photo', style: TextStyle(color: Color(0xFF0D0D0D), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GestureDetector(onTap: () => _pickImage(ImageSource.camera), child: _sheetButton(Icons.camera_alt, 'Take a Photo', 'Take photo from camera')),
              const SizedBox(height: 12),
              GestureDetector(onTap: () => _pickImage(ImageSource.gallery), child: _sheetButton(Icons.photo_library, 'Gallery', 'Choose from Gallery')),
              const SizedBox(height: 12),
              if (_selectedImage != null || _existingImageUrl != null)
                GestureDetector(
                  onTap: () { setState(() { _selectedImage = null; _existingImageUrl = null; }); Navigator.pop(context); },
                  child: _sheetButton(Icons.delete, 'Remove Photo', '', isDelete: true),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetButton(IconData icon, String title, String subtitle, {bool isDelete = false}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFC9A15A), borderRadius: BorderRadius.circular(14), border: isDelete ? Border.all(color: const Color(0xFF0D0D0D)) : null),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFFFFFFF), child: Icon(icon, color: isDelete ? const Color(0xFFC9A15A) : const Color(0xFF0D0D0D))),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Color(0xFF0D0D0D), fontWeight: FontWeight.bold)),
            if(subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Color(0xFF0D0D0D), fontSize: 12)),
          ]),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF0D0D0D), size: 16),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      String? imageUrl = _existingImageUrl;

      if (_selectedImage != null) {
        imageUrl = await _authService.uploadProfileImage(_selectedImage!);
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'street': _streetController.text.trim(),
        'house': _houseController.text.trim(),
        'profileImage': imageUrl,
      });

      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _showBottomSheet,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF0D0D0D),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                          ? NetworkImage(_existingImageUrl!) as ImageProvider
                          : null,
                      child: (_selectedImage == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 50, color: Color(0xFFC9A15A))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0D0D), width: 2)),
                        child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF0D0D0D)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: "Area/City", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: _streetController, decoration: InputDecoration(labelText: "Street", border: OutlineInputBorder())),
            SizedBox(height: 10),
            TextField(controller: _houseController, decoration: InputDecoration(labelText: "House Number", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC9A15A)),
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D0D0D)),
                )
                    : Text("Save Changes", style: TextStyle(color: Color(0xFF0D0D0D), fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC9A15A)),
                onPressed: (){
                  Navigator.pushNamed(context, "/ProfileScreen");
                },
                child: Text("Cancel",style: TextStyle(color: Color(0xFF0D0D0D),fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}