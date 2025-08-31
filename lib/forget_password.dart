import 'package:flutter_app/User_login.dart';
import 'package:flutter_app/profile.dart';
import 'package:flutter_app/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ForgotPasswordApp());
}

class ForgotPasswordApp extends StatelessWidget {
  const ForgotPasswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotPasswordPage(),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Full page white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "At our app, we take the security of your\ninformation seriously.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true, // 👈 hides password text
                decoration: InputDecoration(
                  hintText: "Enter new password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email', isError: true);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your new password', isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar(
        'Password must be at least 6 characters long',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/forget-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'newPassword': _passwordController.text,
        }),
      );

      if (res.statusCode == 200) {
        // Check if response body is not empty
        if (res.body.isNotEmpty) {
          try {
            final data = jsonDecode(res.body);
            _showSnackBar('Password reset successful!', isError: false);

            // Navigate to welcome screen after successful reset
            await Future.delayed(const Duration(seconds: 1));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          } catch (e) {
            _showSnackBar('Invalid response from server', isError: true);
            print('JSON decode error: $e'); // For debugging
          }
        } else {
          _showSnackBar('Password reset successful!', isError: false);
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      } else {
        try {
          if (res.body.isNotEmpty) {
            final data = jsonDecode(res.body);
            _showSnackBar(
              data['message'] ?? 'Password reset failed',
              isError: true,
            );
          } else {
            _showSnackBar('Password reset failed', isError: true);
          }
        } catch (e) {
          _showSnackBar('Password reset failed', isError: true);
          print('JSON decode error: $e'); // For debugging
        }
      }
    } catch (e) {
      _showSnackBar(
        'Network error. Please check your connection and try again.',
        isError: true,
      );
      print('Error: $e'); // For debugging
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
