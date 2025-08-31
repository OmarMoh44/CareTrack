import 'package:caretrack/appo_datetime.dart';
import 'package:caretrack/our_doctors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

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
      doctorSpeciality: _formatSpecialty(json['doctorSpeciality'] ?? ''),
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

  static String _formatSpecialty(String specialty) {
    switch (specialty.toUpperCase()) {
      case 'CARDIOLOGY':
        return 'Cardiologist';
      case 'DERMATOLOGY':
        return 'Dermatologist';
      case 'NEUROLOGY':
        return 'Neurologist';
      case 'ORTHOPEDICS':
        return 'Orthopedic';
      case 'OPHTHALMOLOGY':
        return 'Ophthalmologist';
      case 'OTOLARYNGOLOGY':
        return 'ENT Specialist';
      default:
        return specialty;
    }
  }

  // Add getters to match home page and doctor details expectations
  String get specialization => doctorSpeciality;
  int get fee => double.tryParse(consultationFee.toString())?.toInt() ?? 500;
}

void main() {
  runApp(const DrDetails());
}

class DrDetails extends StatelessWidget {
  const DrDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DoctorDetailsScreen(),
    );
  }
}

class DoctorDetailsScreen extends StatefulWidget {
  final dynamic
  doctor; // Accept doctor data (could be doctor ID or full doctor object)
  final String? doctorId; // Specific doctor ID to fetch
  final Widget? previousPage; // Accept previous page info

  const DoctorDetailsScreen({
    super.key,
    this.doctor,
    this.doctorId,
    this.previousPage,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? doctor;
  bool isLoading = true;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get the stored authentication token
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fetch doctor data from backend API
  Future<Map<String, dynamic>?> _fetchDoctorFromAPI({
    String? specificDoctorId,
  }) async {
    try {
      _authToken = await _getAuthToken();

      if (_authToken == null) {
        _showError('Authentication Error', 'Please login again');
        return null;
      }

      // Fixed API URL construction
      String apiUrl =
          'http://10.0.2.2:8080/api/patient/doctors/$specificDoctorId';

      print('Fetching doctor from: $apiUrl'); // Debug log

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle different response structures
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is List && responseData.isNotEmpty) {
          return responseData.first;
        }
      } else if (response.statusCode == 401) {
        _showError(
          'Authentication Error',
          'Session expired. Please login again',
        );
      } else {
        _showError(
          'Error',
          'Failed to load doctor data: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching doctor: $e'); // Debug log
      _showError('Network Error', 'Failed to connect to server: $e');
    }
    return null;
  }

  Future<void> _loadData() async {
    try {
      Map<String, dynamic>? doctorData;
      String? doctorIdToFetch;

      // Extract doctor ID from various sources
      if (widget.doctorId != null) {
        doctorIdToFetch = widget.doctorId;
      } else if (widget.doctor != null) {
        if (widget.doctor is Map<String, dynamic>) {
          doctorIdToFetch = widget.doctor['id']?.toString();
        } else if (widget.doctor is Doctor) {
          doctorIdToFetch = widget.doctor.id?.toString();
        } else {
          // Try to get ID from doctor object properties
          try {
            doctorIdToFetch = widget.doctor.id?.toString();
          } catch (e) {
            print('Could not extract doctor ID: $e');
          }
        }
      }

      if (doctorIdToFetch != null) {
        print('Fetching doctor with ID: $doctorIdToFetch'); // Debug log
        doctorData = await _fetchDoctorFromAPI(
          specificDoctorId: doctorIdToFetch,
        );
      }

      // Fallback to passed data if API fetch fails
      if (doctorData == null && widget.doctor != null) {
        print('Using passed doctor data as fallback'); // Debug log
        doctorData = _convertDoctorToMap(widget.doctor);
      }

      if (doctorData != null) {
        setState(() {
          doctor = _normalizeDocForMap(doctorData!);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error', 'Could not load doctor information');
      }
    } catch (e) {
      print('Error in _loadData: $e'); // Debug log
      setState(() {
        isLoading = false;
      });
      _showError('Error', 'Failed to load doctor data: $e');
    }
  }

  // Normalize doctor data to ensure consistent format
  Map<String, dynamic> _normalizeDocForMap(Map<String, dynamic> apiData) {
    return {
      "id": apiData['id']?.toString() ?? '',
      "name": apiData['name'] ?? apiData['fullName'] ?? 'Dr. Unknown',
      "specialization": _formatSpecialty(
        apiData['specialization'] ??
            apiData['doctorSpeciality'] ??
            apiData['specialty'] ??
            'General Practice',
      ),
      "price": _formatPrice(
        apiData['fee'] ?? apiData['price'] ?? apiData['consultationFee'],
      ),
      "rating": "4.5", // Default rating since it's not in your API
      "distance": "${apiData['city'] ?? 'Cairo'}, Egypt",
      "about":
          apiData['info'] ??
          apiData['bio'] ??
          apiData['description'] ??
          "This doctor is a qualified medical professional with expertise in their field. They are available for consultation and treatment.",
      "workingTime": _formatWorkingTime(
        apiData['startTime'],
        apiData['endTime'],
        apiData['availableDays'],
      ),
      "location":
          "${apiData['street'] ?? ''}, ${apiData['city'] ?? 'Cairo'}, Egypt"
              .replaceAll(RegExp(r'^,\s*'), ''),
      "phone": apiData['phone'] ?? apiData['phoneNumber'] ?? '',
      "email": apiData['email'] ?? '',
      "experience": "${apiData['patientNumber'] ?? 0}+ patients treated",
      "qualification":
          "MD - ${_formatSpecialty(apiData['doctorSpeciality'] ?? 'General Practice')}",
    };
  }

  String _formatSpecialty(String specialty) {
    switch (specialty.toUpperCase()) {
      case 'CARDIOLOGY':
        return 'Cardiologist';
      case 'DERMATOLOGY':
        return 'Dermatologist';
      case 'NEUROLOGY':
        return 'Neurologist';
      case 'ORTHOPEDICS':
        return 'Orthopedic Surgeon';
      case 'OPHTHALMOLOGY':
        return 'Ophthalmologist';
      case 'OTOLARYNGOLOGY':
        return 'ENT Specialist';
      default:
        return specialty.isNotEmpty ? specialty : 'General Practice';
    }
  }

  String _formatWorkingTime(
    String? startTime,
    String? endTime,
    List<dynamic>? availableDays,
  ) {
    String days = "Monday - Friday";
    if (availableDays != null && availableDays.isNotEmpty) {
      days = availableDays.join(', ');
    }

    String time = "08:00 AM - 06:00 PM";
    if (startTime != null && endTime != null) {
      time = "$startTime - $endTime";
    }

    return "$days, $time";
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '500 LE';
    if (price is String && price.contains('LE')) return price;
    return '$price LE';
  }

  Map<String, dynamic> _convertDoctorToMap(dynamic doctorData) {
    // Convert Doctor object to Map if needed
    if (doctorData is Map<String, dynamic>) {
      return _normalizeDocForMap(doctorData);
    }

    // If it's a Doctor class instance, convert it
    try {
      return {
        "id": doctorData.id?.toString() ?? '',
        "name": doctorData.fullName ?? "Dr. Unknown",
        "specialization": _formatSpecialty(
          doctorData.doctorSpeciality ?? "General Practice",
        ),
        "rating": "4.5",
        "distance": "${doctorData.city ?? 'Cairo'}, Egypt",
        "price": _formatPrice(doctorData.consultationFee),
        "about": doctorData.info.isNotEmpty
            ? doctorData.info
            : "Dr. ${doctorData.fullName ?? 'Unknown'} is a qualified specialist in ${_formatSpecialty(doctorData.doctorSpeciality ?? 'General Practice')}. They are available for consultation and treatment.",
        "workingTime": _formatWorkingTime(
          doctorData.startTime,
          doctorData.endTime,
          doctorData.availableDays,
        ),
        "location": "${doctorData.street}, ${doctorData.city}, Egypt"
            .replaceAll(RegExp(r'^,\s*'), ''),
        "phone": doctorData.phoneNumber ?? '',
        "email": doctorData.email ?? '',
        "experience": "${doctorData.patientNumber}+ patients treated",
        "qualification":
            "MD - ${_formatSpecialty(doctorData.doctorSpeciality)}",
      };
    } catch (e) {
      print('Error converting doctor data: $e');
      return {
        "id": '',
        "name": "Dr. Unknown",
        "specialization": "General Practice",
        "rating": "4.5",
        "distance": "Cairo, Egypt",
        "price": "500 LE",
        "about": "This doctor is available for consultation.",
        "workingTime": "Monday - Friday, 08:00 AM - 06:00 PM",
        "location": "Cairo, Egypt",
        "phone": '',
        "email": '',
        "experience": "5+ years",
        "qualification": "MD",
      };
    }
  }

  void _showError(String title, String message) {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.previousPage != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => widget.previousPage!),
              );
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
        title: Text(
          doctor?["name"] ?? "Doctor Details",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.black),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading doctor information...'),
                ],
              ),
            )
          : doctor == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Failed to load doctor information'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Doctor Info Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor!["name"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor!["specialization"],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  Text(
                                    " ${doctor!["rating"]}",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  Expanded(
                                    child: Text(
                                      doctor!["distance"],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          doctor!["price"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "About"),
                    Tab(text: "Location"),
                  ],
                ),

                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // About Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "About me",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctor!["about"],
                              style: const TextStyle(
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Working Time",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctor!["workingTime"],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            if (doctor!["experience"] != null) ...[
                              const Text(
                                "Experience",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                doctor!["experience"],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (doctor!["qualification"] != null) ...[
                              const Text(
                                "Qualification",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                doctor!["qualification"],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Location Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Practice Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctor!["location"],
                              style: const TextStyle(
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (doctor!["phone"] != null &&
                                doctor!["phone"].toString().isNotEmpty) ...[
                              const Text(
                                "Phone",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    doctor!["phone"],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (doctor!["email"] != null &&
                                doctor!["email"].toString().isNotEmpty) ...[
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    doctor!["email"],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Make Appointment Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppoDatetime(
                            doctorId: int.parse(doctor!["id"].toString()),
                            consultationFee:
                                double.tryParse(
                                  doctor!["price"].toString().replaceAll(
                                    RegExp(r'[^\d.]'),
                                    '',
                                  ),
                                ) ??
                                0.0,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Make An Appointment",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
