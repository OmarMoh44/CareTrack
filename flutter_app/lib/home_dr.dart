import 'dart:convert';
import 'package:flutter_app/dr_appo.dart';
import 'package:flutter_app/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------ MODEL ------------------
class DoctorProfile {
  final String name;
  final String email;
  final String specialty;

  DoctorProfile({
    required this.name,
    required this.email,
    required this.specialty,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      name: json["fullName"] ?? "Unknown",
      email: json["email"] ?? "unknown@email.com",
      specialty: json["doctorSpeciality"] ?? "Unknown",
    );
  }
}

/// ------------------ REPOSITORY ------------------
class DoctorProfileRepository {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<DoctorProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) throw Exception("No auth token found");

    final res = await http.get(
      Uri.parse("$baseUrl/doctor"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Profile response: ${res.statusCode} ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return DoctorProfile.fromJson(data);
    } else {
      throw Exception("Failed to load profile");
    }
  }
}

/// ------------------ CUBIT ------------------
class DoctorProfileCubit extends Cubit<DoctorProfile?> {
  final DoctorProfileRepository repository;
  DoctorProfileCubit(this.repository) : super(null);

  Future<void> loadProfile() async {
    try {
      final profile = await repository.getProfile();
      emit(profile);
    } catch (e) {
      print("Error loading profile: $e");
      emit(null);
    }
  }
}

/// ------------------ MAIN APP ------------------
void main() {
  runApp(const HomeDr());
}

class HomeDr extends StatelessWidget {
  const HomeDr({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "You'll need to enter your username and password next time you want to login",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("auth_token");
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Color(0xFFEC0E11),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create:
            (context) =>
                DoctorProfileCubit(DoctorProfileRepository())..loadProfile(),
        child: Scaffold(
          backgroundColor: const Color(0xFFDFEFFF),
          appBar: AppBar(
            toolbarHeight: 60,
            centerTitle: true,
            backgroundColor: const Color(0xFFDFEFFF),
            elevation: 0,
            title: const Text(
              'Welcome Doctor!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.92,
                  padding: const EdgeInsets.only(bottom: 24, top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 0, bottom: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8D5F2),
                          shape: BoxShape.circle,
                        ),
                        width: 75,
                        height: 75,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipOval(
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      BlocBuilder<DoctorProfileCubit, DoctorProfile?>(
                        builder: (context, profile) {
                          return Column(
                            children: [
                              Text(
                                profile?.name ?? "Dr. Loading...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                profile?.email ?? "Loading...",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                profile?.specialty ?? "Loading...",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star_half, color: Colors.amber, size: 18),
                          SizedBox(width: 7),
                          Text(
                            "4.7 ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "(rating)",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 260,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0080FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text(
                            'Upcoming Appointments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DrAppo()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.92,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFEC0E11),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
