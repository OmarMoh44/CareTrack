import 'package:caretrack/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const PersonalInfo());
}

class PersonalInfo extends StatelessWidget {
  const PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Info',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PersonalInformationPage(),
    );
  }
}

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isPasswordVisible = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Get the stored authentication token
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Load user data from the backend
  Future<void> _loadUserData() async {
    try {
      _authToken = await _getAuthToken();

      if (_authToken == null) {
        _showError('Authentication Error', 'Please login again');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Populate the form fields with the retrieved data
        setState(() {
          nameController.text = userData['fullName'] ?? '';
          emailController.text = userData['email'] ?? '';
          phoneController.text = userData['phoneNumber'] ?? '';
          // Don't populate password field for security reasons
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _showError(
          'Authentication Error',
          'Session expired. Please login again',
        );
      } else {
        _showError('Error', 'Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network Error', 'Failed to connect to server: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Save user data to the backend
  Future<void> _saveUserInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_authToken == null) {
        _showError('Authentication Error', 'Please login again');
        return;
      }

      // Prepare the data to send
      Map<String, dynamic> userData = {
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
      };

      // Only include password if it's not empty
      if (passwordController.text.isNotEmpty) {
        userData['password'] = passwordController.text;
      }

      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8080/api/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Personal information saved successfully!');
        // Clear password field after successful save for security
        passwordController.clear();
      } else if (response.statusCode == 401) {
        _showError(
          'Authentication Error',
          'Session expired. Please login again',
        );
      } else {
        final errorMessage = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ?? 'Save failed'
            : 'Save failed';
        _showError('Save Failed', errorMessage);
      }
    } catch (e) {
      _showError('Network Error', 'Failed to save data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          'Personal information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your information...'),
                ],
              ),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.purple[100],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.brown,
                        ),
                      ),

                      const SizedBox(height: 40),

                      buildTextField(
                        controller: nameController,
                        hint: 'Full Name',
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      buildTextField(
                        controller: emailController,
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            isValidEmail(value!) ? null : 'Enter a valid email',
                      ),
                      const SizedBox(height: 20),

                      buildTextField(
                        controller: passwordController,
                        hint: 'New Password (leave empty to keep current)',
                        obscureText: !isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => isPasswordVisible = !isPasswordVisible,
                            );
                          },
                        ),
                        validator: (value) {
                          // Password is optional for updates
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      buildTextField(
                        controller: phoneController,
                        hint: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                            return 'Please enter a valid 11-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      Text(
                        'Please provide accurate information to avoid any issues.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveUserInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}
