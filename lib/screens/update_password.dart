import 'package:flutter/material.dart';

import '../firebase_auth/auth_service.dart';

class UpdatePassword extends StatelessWidget{
  UpdatePassword({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF0D0D0D)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height:100),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock, size: 50, color: Color(0xFFC9A15A)),
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Color(0xFFC9A15A)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!value.contains("@") || !value.contains(".")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC9A15A),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()){
                    String? errorMessage = await _authService.resetPassword(_emailController.text.trim());
                    if(!context.mounted)return;
                    if(errorMessage == null){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content : Text("Password Reset Link Send! Check Your Email")),
                      );
                      Navigator.pop(context);
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content : Text(errorMessage)),
                      );
                    }
                  }
                },
                child: const Text("Enter Email to Continue",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF0D0D0D))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}