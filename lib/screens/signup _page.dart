import 'package:flutter/material.dart';

import '../firebase_auth/auth_service.dart';
class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() =>  _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  @override
  void initState(){
    super.initState();
  }
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
   return Scaffold(
     appBar: AppBar(
       title: const Text(
         "Sign Up",
         style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
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
           const SizedBox(height: 10),
           Container(
             padding: EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Color(0xFF1A1F36),
               borderRadius: BorderRadius.circular(10),
             ),
             child: const Icon(
               Icons.group_add,
               size: 50,
               color: Color(0xFFFFD700),
             ),
           ),
           const SizedBox(height: 20),
           const Text(
             "Create  Account",
             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF212529)),
           ),
           const SizedBox(height: 10),
           const Text(
             "Sign Up to Get Started",
             style: TextStyle(fontSize: 16, color: Color(0xFF212529)),
           ),
           const SizedBox(height: 20),
           TextField(
             controller: _firstNameController,
             decoration: InputDecoration(
               labelText: "First Name",
               border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.drive_file_rename_outline, color: Color(0xFFFFD700))
             ),
           ),
             const SizedBox(height: 10),
           TextField(
             controller: _lastNameController,
             decoration: InputDecoration(
               labelText: "Last Name",
               border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.drive_file_rename_outline, color: Color(0xFFFFD700))
             ),
           ),
           const SizedBox(height: 10),
           TextFormField(
             controller: _emailController,
             decoration: InputDecoration(
               labelText: "Email",
               border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.email, color: Color(0xFFFFD700))
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
           const SizedBox(height: 10),
           TextFormField(
             controller: _passwordController,
             obscureText: !_isPasswordVisible,
             decoration: InputDecoration(
               labelText: "New Password",
               border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.lock, color: Color(0xFFFFD700)),
               suffixIcon: IconButton(
                 icon: Icon(
                   _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                   color: Color(0xFFFFD700),
                 ),
                 onPressed: () {
                   setState(() {
                     _isPasswordVisible = !_isPasswordVisible;
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
           const SizedBox(height:10),
           TextFormField(
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
           const SizedBox(height: 10),
           ElevatedButton(
             style: ElevatedButton.styleFrom(
               backgroundColor: Color(0xFFFFD700),
             ),
             onPressed: () async{
               if (_formKey.currentState!.validate()) {
                 String email = _emailController.text;
                 String password = _passwordController.text;
                 String firstName = _firstNameController.text;
                 String lastName = _lastNameController.text;
                 String? errorMessage = await _authService.signUp(firstName,lastName,email, password);
                 if (errorMessage == null) {
                   Navigator.pushNamedAndRemoveUntil(context, "/homepage", (route) => false);
                 }else{
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text(errorMessage),
                     ),
                   );
                 }
               }
             },
             child: const Text(
                 "Sign Up",
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
             ),
           ),
           const SizedBox(height: 10),
           TextButton(
             onPressed: () {
               Navigator.pop(context);
             },
             child: const Text(
                 "Already have an account? Login",
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
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