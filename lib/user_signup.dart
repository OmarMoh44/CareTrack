//user signup
import 'dart:convert';
import 'package:caretrack/User_login.dart';
import 'package:caretrack/home_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(UserSignup());
}

class UserSignup extends StatelessWidget {
  UserSignup({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/register/patient'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'fullName': _fullNameController.text,
          'phoneNumber': _phoneController.text,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final responseData = jsonDecode(res.body);
        final token = responseData['token'] as String;

        // Save the token and user role
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeUser()),
        );
      } else {
        final errorData = jsonDecode(res.body);
        final errorMessage = errorData['message'] ?? 'Registration failed';
        _showError(context, 'Failed to register', errorMessage);
      }
    } catch (e) {
      _showError(context, 'Network error', e.toString());
    }
  }

  void _showError(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Create account',
                      style: TextStyle(
                        color: const Color(0xFF0080FF),
                        fontSize: isSmallScreen ? 24 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'SignUp to continue',
                      style: TextStyle(
                        color: const Color(0xFF0080FF),
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Full name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Full name is required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email is required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Password is required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Phone number is required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0080FF),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _register(context),
                        child: Text(
                          'Create Account',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserLogin(),
                              ),
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
