import 'package:flutter_app/dr_details.dart';
import 'package:flutter_app/home_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Use the same Doctor class from home_user.dart
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
  final String? profileImage;

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
    this.profileImage,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? 'Doctor',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      doctorSpeciality: json['doctorSpeciality'] ?? 'General Medicine',
      info: json['info'] ?? '',
      patientNumber: json['patientNumber'] ?? 0,
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '17:00',
      consultationFee:
          (json['consultationFee'] is String)
              ? double.tryParse(json['consultationFee']) ?? 0.0
              : (json['consultationFee']?.toDouble() ?? 0.0),
      availableDays:
          (json['availableDays'] as List<dynamic>?)
              ?.map((day) => day.toString())
              .toList() ??
          ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      role: json['role'] ?? 'DOCTOR',
      profileImage: json['profileImage'],
    );
  }

  // Add getters to match the old Doctor class properties for UI compatibility
  String get name => fullName;
  String get specialty => doctorSpeciality;
  double get rating => 4.7; // Default rating since API doesn't provide it
  String get distance => '$city, $street';
  String get price => "${consultationFee.toStringAsFixed(0)} LE";
  String get specialization => doctorSpeciality;
  int get fee => consultationFee.toInt();
}

void main() {
  runApp(OurDoctors());
}

class OurDoctors extends StatelessWidget {
  const OurDoctors({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OurDoctorsScreen(),
    );
  }
}

class OurDoctorsScreen extends StatefulWidget {
  const OurDoctorsScreen({super.key});

  @override
  State<OurDoctorsScreen> createState() => _OurDoctorsScreenState();
}

class _OurDoctorsScreenState extends State<OurDoctorsScreen> {
  List<Doctor> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsData();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchDoctorsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await _getAuthToken();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/patient/doctors-search'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'city': 'ALL', 'doctorSpeciality': 'ALL'}),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> data;
        if (decodedData is List) {
          data = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('doctors')) {
          data = decodedData['doctors'] as List<dynamic>;
        } else {
          data = [decodedData];
        }

        setState(() {
          doctors = data.map((json) => Doctor.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctors data: $e');
      setState(() {
        doctors = [];
        isLoading = false;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeUser()),
              );
            }
          },
        ),
        title: const Text(
          'Our Doctors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFDFF1FF),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : doctors.isEmpty
              ? const Center(
                child: Text(
                  'No doctors available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: doctors.length,
                separatorBuilder: (_, __) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onDoctorTapped(doctor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  doctor.specialty,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      doctor.rating.toString(),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      doctor.distance,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            doctor.price,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
