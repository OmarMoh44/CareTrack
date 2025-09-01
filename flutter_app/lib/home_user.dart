import 'package:flutter_app/dr_details.dart';
import 'package:flutter_app/our_doctors.dart';
import 'package:flutter_app/profile.dart';
import 'package:flutter_app/search.dart';
import 'package:flutter_app/user_appo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const HomeUser());
}

class HomeUser extends StatelessWidget {
  const HomeUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Doctor {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String city;
  final String street;
  final String doctorSpeciality;
  final String info;
  final int patientNumber;
  final String startTime;
  final String endTime;
  final double consultationFee;
  final List<String> availableDays;
  final int id;
  final String role;

  const Doctor({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.street,
    required this.doctorSpeciality,
    required this.info,
    required this.patientNumber,
    required this.startTime,
    required this.endTime,
    required this.consultationFee,
    required this.availableDays,
    required this.id,
    required this.role,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? 'Unknown Doctor',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      doctorSpeciality: json['doctorSpeciality'] ?? 'General Physician',
      info: json['info'] ?? '',
      patientNumber: json['patientNumber'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      consultationFee: json['consultationFee'] ?? 0,
      availableDays:
          (json['availableDays'] as List<dynamic>?)
              ?.map((day) => day.toString())
              .toList() ??
          [],
      role: json['role'] ?? 'USER',
    );
  }
}

class Patient {
  final String name;
  final int? id;

  const Patient({required this.name, this.id});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(id: json['id'], name: json['fullName'] ?? 'User');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Doctor> doctors = [];
  Patient? patient;
  bool isLoadingDoctors = true;
  bool isLoadingPatient = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
    _fetchDoctorsData();
  }

  Future<void> _fetchPatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          patient = Patient.fromJson(data);
          isLoadingPatient = false;
        });
      } else {
        throw Exception('Failed to load patient data');
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      setState(() {
        patient = const Patient(name: 'User'); // fallback
        isLoadingPatient = false;
      });
    }
  }

  Future<void> _fetchDoctorsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/patient/doctors-search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'city': 'ALL', 'doctorSpeciality': 'ALL'}),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        final List<dynamic> data =
            decodedData is List ? decodedData : [decodedData];
        setState(() {
          doctors = data.map((json) => Doctor.fromJson(json)).toList();
          isLoadingDoctors = false;
        });
      } else {
        throw Exception('Failed to load doctors data');
      }
    } catch (e) {
      print('Error fetching doctors data: $e');
      setState(() {
        doctors = [];
        isLoadingDoctors = false;
      });
    }
  }

  void _onDoctorTapped(Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // ==== Header ====
          Container(
            height: screenHeight * 0.4,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Search()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Search', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 5),
                            isLoadingPatient
                                ? const CircularProgressIndicator()
                                : Text(
                                  patient?.name ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                            const SizedBox(height: 8),
                            const Text(
                              'How is going today?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 140,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/doctor.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ==== Doctors Section ====
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Our Doctors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OurDoctors()),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF247CFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // ==== Doctors List ====
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchDoctorsData,
              child: Builder(
                builder: (context) {
                  if (isLoadingDoctors) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (doctors.isEmpty) {
                    return const Center(
                      child: Text(
                        'No doctors available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: doctors.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () => _onDoctorTapped(doctor),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // ==== Bottom Navigation ====
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFBBDEFB),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blue, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserAppo()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.grey, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.doctorSpeciality,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text('${doctor.city}, ${doctor.street}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('${doctor.startTime} - ${doctor.endTime}'),
              const SizedBox(height: 8),
              Text(
                '${doctor.consultationFee} LE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
