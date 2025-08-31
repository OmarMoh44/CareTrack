import 'dart:convert';
import 'package:caretrack/doctor_login.dart';
import 'package:caretrack/home_dr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const DoctorSignup());
}

class DoctorSignup extends StatefulWidget {
  const DoctorSignup({Key? key}) : super(key: key);

  @override
  State<DoctorSignup> createState() => _MyAppState();
}

class _MyAppState extends State<DoctorSignup> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // maps to fullName
  final _costController = TextEditingController(); // maps to consultationFee
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _infoController = TextEditingController();
  final _patientNumberController = TextEditingController();
  final _startTimeController = TextEditingController(text: '09:00');
  final _endTimeController = TextEditingController(text: '17:00');

  final List<String> _specialties = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Ophthalmology',
    'Otolaryngology',
  ];

  String? _selectedSpecialty;
  bool _loading = false;

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final body = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "fullName": _usernameController.text,
        "phoneNumber": _phoneController.text,
        "city": _cityController.text.toUpperCase(),
        "street": _streetController.text,
        "doctorSpeciality": (_selectedSpecialty ?? 'Cardiology').toUpperCase(),
        "info": _infoController.text,
        "patientNumber": _patientNumberController.text,
        "startTime": _startTimeController.text,
        "endTime": _endTimeController.text,
        "consultationFee": double.tryParse(_costController.text) ?? 25.0,
        "availableDays": [
          "MONDAY",
          "TUESDAY",
          "WEDNESDAY",
          "THURSDAY",
          "FRIDAY",
        ],
      };
      print(jsonEncode(body));
      final res = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/register/doctor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final responseData = jsonDecode(res.body);
        final token = responseData['token'] as String;

        // Save the token and user role
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeDr()),
        );
      } else {
        final errorData = jsonDecode(res.body);
        final errorMessage = errorData['message'] ?? 'Registration failed';
        _showError('Failed to register', errorMessage);
      }
    } catch (e) {
      _showError('Network error', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String title, String message) {
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _costController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _infoController.dispose();
    _patientNumberController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 400;

          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create account as a doctor',
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
                          width: double.infinity,
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
                          width: double.infinity,
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Full Name is required';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _costController,
                            decoration: InputDecoration(
                              hintText: 'Cost',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.money),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Cost is required';
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButtonFormField<String>(
                            value: _selectedSpecialty,
                            items: _specialties
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedSpecialty = value),
                            decoration: InputDecoration(
                              hintText: "Specialty",
                              prefixIcon: const Icon(Icons.local_hospital),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value == null
                                ? 'Please select a specialty'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Phone number',
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
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  hintText: 'City',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.location_city),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'City is required';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _streetController,
                                decoration: InputDecoration(
                                  hintText: 'Street',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.add_road),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Street is required';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _infoController,
                            decoration: InputDecoration(
                              hintText: 'Additional Information',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.info),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _startTimeController,
                                decoration: InputDecoration(
                                  hintText: 'Start Time (HH:mm)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Start time is required';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _endTimeController,
                                decoration: InputDecoration(
                                  hintText: 'End Time (HH:mm)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'End time is required';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _patientNumberController,
                            decoration: InputDecoration(
                              hintText: 'Patient Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.badge),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Patient Number is required';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.password),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Password is required';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0080FF),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _loading ? null : _registerDoctor,
                            child: _loading
                                ? const CircularProgressIndicator()
                                : Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 18,
                                    ),
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
                                    builder: (context) => const DoctorLogin(),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
