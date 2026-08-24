import 'package:flutter/material.dart';
class ForgetPassword extends StatefulWidget{
  const ForgetPassword({super.key});
  @override
  State<ForgetPassword> createState() => _ForgetPasswordScreen();
}
class _ForgetPasswordScreen extends State<ForgetPassword>{
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  @override
  void initState(){
    super.initState();
  }
  @override
  void dispose(){
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF212529)),
        ),
      ),
    body: SingleChildScrollView(
      child: Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock, size: 70, color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock, color: Color(0xFFFFD700)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Color(0xFFFFD700),
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              if (value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock, color: Color(0xFFFFD700)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Color(0xFFFFD700),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              if (value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD700),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String newPassword = _newPasswordController.text;
                String confirmPassword = _confirmPasswordController.text;
                Navigator.pushNamed(context, "/login");
              }
            },
            child: const Text(
                "Update Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF1A1F36)),
            ),
          ),
        ],
      ),
    ),
    ),
    ),
    );
  }
}