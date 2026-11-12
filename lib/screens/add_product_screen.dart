import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AddProductScreen extends StatefulWidget {
  // Agar productId + existingData diye jayen to ye EDIT mode mein chalega
  final String? productId;
  final Map<String, dynamic>? existingData;

  const AddProductScreen({super.key, this.productId, this.existingData});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "Men";
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isUploading = false;
  bool _isCheckingAdmin = true;
  bool _isAdmin = false;

  final ImagePicker _picker = ImagePicker();
  final cloudinary = CloudinaryPublic('pqgou8fa', 'ml_default', cache: false);

  bool get isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _checkAdmin();

    if (isEditMode && widget.existingData != null) {
      final data = widget.existingData!;
      _nameController.text = data['name'] ?? '';
      _priceController.text = data['price'].toString();
      _descriptionController.text = data['description'] ?? '';
      _selectedCategory = data['category'] ?? 'Men';
      _existingImageUrl = data['image'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkAdmin() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    setState(() {
      _isAdmin = data?['isAdmin'] ?? false;
      _isCheckingAdmin = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Naye product ke liye image zaroori hai; edit mein purani image chal sakti hai
    if (_selectedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a product image")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      // Sirf tab upload karo jab nayi image select ki gayi ho
      if (_selectedImage != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImage!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        imageUrl = response.secureUrl;
      }

      final productData = {
        'name': _nameController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'image': imageUrl,
      };

      if (isEditMode) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);
      } else {
        productData['createdAt'] = DateTime.now();
        await FirebaseFirestore.instance.collection('products').add(productData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? "Product updated" : "Product added successfully")),
      );

      if (isEditMode) {
        Navigator.pop(context);
      } else {
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedImage = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAdmin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC9A15A))),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("Add Product")),
        body: const Center(
          child: Text(
            "You are not authorized to access this page",
            style: TextStyle(fontSize: 16, color: Color(0xFF212529)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Product" : "Add Product",
          style: const TextStyle(color: Color(0xFF0D0D0D), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EAD9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF0D0D0D)),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                      : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                  )
                      : const Center(
                    child: Icon(Icons.add_a_photo, size: 40, color: Color(0xFFC9A15A)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap image to change",
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Product name is required" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (PKR)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Price is required";
                  if (int.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Description is required" : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Men", child: Text("Men")),
                  DropdownMenuItem(value: "Women", child: Text("Women")),
                  DropdownMenuItem(value: "Kids", child: Text("Kids")),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A15A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isUploading ? null : _saveProduct,
                  child: _isUploading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D0D0D)),
                  )
                      : Text(
                    isEditMode ? "Save Changes" : "Add Product",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}