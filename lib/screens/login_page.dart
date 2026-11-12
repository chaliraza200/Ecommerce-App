import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isAdminLogin = false;
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

  Widget _buildSocialButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC9A15A), width: 1.5),
        ),
        child: Icon(icon, size: 28, color: const Color(0xFFC9A15A)),
      ),
    );
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
                    color: Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:const Icon(
                    Icons.people,
                    size: 50,
                    color: Color(0xFFC9A15A),
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration:InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFFC9A15A)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFFC9A15A),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("User"),
                      selected: !_isAdminLogin,
                      onSelected: (selected) => setState(() => _isAdminLogin = false),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Admin"),
                      selected: _isAdminLogin,
                      onSelected: (selected) => setState(() => _isAdminLogin = true),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC9A15A),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String? errorMessage = await _authService.signIn(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                        if (!context.mounted) return;

                        if (errorMessage == null) {
                          String uid = FirebaseAuth.instance.currentUser!.uid;
                          DocumentSnapshot userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .get();

                          bool isAdmin = false;
                          if (userDoc.exists) {
                            final data = userDoc.data() as Map<String, dynamic>;
                            isAdmin = data['isAdmin'] ?? false;
                          }

                          if (!context.mounted) return;

                          if (_isAdminLogin) {
                            if (isAdmin) {
                              Navigator.pushNamedAndRemoveUntil(context, "/adminPanel", (route) => false);
                            } else {
                              await _authService.signOut();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("This account is not authorized as Admin")),
                              );
                            }
                          } else {
                            Navigator.pushNamedAndRemoveUntil(context, "/homepage", (route) => false);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                        }
                      }
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/UpdatePassword");
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D)),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/signup");
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D0D0D)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFF212529).withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(color: Color(0xFF212529).withOpacity(0.6), fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFF212529).withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      onTap: () async {
                        String? errorMessage = await _authService.signInWithGoogle();
                        if (!context.mounted) return;
                        if (errorMessage == null) {
                          Navigator.pushNamedAndRemoveUntil(context, "/homepage", (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.phone,
                      onTap: () {
                        Navigator.pushNamed(context, "/PhoneScreen");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}