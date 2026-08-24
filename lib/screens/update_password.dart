import 'package:flutter/material.dart';

class UpdatePassword extends StatelessWidget{
  UpdatePassword({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
@override
 Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Update Password",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF1A1F36)),
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
              color: Color(0xFF1A1F36),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock, size: 50, color: Color(0xFFFFD700)),
          ),
          const SizedBox(height: 50),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email, color: Color(0xFFFFD700)),
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
              backgroundColor: Color(0xFFFFD700),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String email = _emailController.text;
                Navigator.pushNamed(context, "/ForgotPassword");
              }
            },
            child: const Text("Enter Email to Continue",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF1A1F36))),
          ),
        ],
      ),
    ),
    ),
  );
}
}