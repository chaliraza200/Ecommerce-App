import 'package:flutter/material.dart';
import '../firebase_auth/auth_service.dart';
class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1A1F36),
              borderRadius: BorderRadius.circular(10),
            ),
            child:const Icon(
              Icons.people,
              size: 50,
              color: Color(0xFFFFD700),
            ),
            ),
            const SizedBox(height: 20),
            const Text(
                "Welcome  Back",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Login to Continue",
              style: TextStyle(fontSize: 16, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border:OutlineInputBorder(),
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
        const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration:InputDecoration(
                labelText: "Password",
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
             const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
              ),
              onPressed: () async{
                if (_formKey.currentState!.validate()) {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  String? errorMessage = await _authService.signIn(email, password);
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
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/UpdatePassword");
              },
              child: const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/signup");
              },
              child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
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