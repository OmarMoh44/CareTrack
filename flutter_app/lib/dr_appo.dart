import 'dart:convert';
import 'package:flutter_app/home_dr.dart';
import 'package:flutter_app/medical_record.dart';
import 'package:flutter_app/add_medical_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------ MODELS ------------------
class Appointment {
  final int id;
  final int patientId; // ✅ added patientId
  final String patientName;
  final String patientEmail;
  final String date;
  final String startTime;
  final String endTime;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json["id"] ?? 0,
      patientId: json["patientId"] ?? 0, // ✅ make sure backend provides this
      patientName: json["patientName"] ?? "Unknown",
      patientEmail: json["patientEmail"] ?? "unknown@email.com",
      date: json["date"] ?? "N/A",
      startTime: json["doctorStartTime"] ?? "N/A",
      endTime: json["doctorEndTime"] ?? "N/A",
    );
  }
}

/// ------------------ REPOSITORIES ------------------
class DoctorAppointmentRepository {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<List<Appointment>> getDoctorAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) throw Exception("No auth token found");

    final res = await http.get(
      Uri.parse("$baseUrl/appointments"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Doctor appointments response: ${res.statusCode} ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        return [Appointment.fromJson(data)];
      }
    } else {
      throw Exception("Failed to load doctor appointments");
    }
  }

  Future<void> cancelAppointment(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) throw Exception("No auth token found");

    final res = await http.delete(
      Uri.parse("$baseUrl/appointments/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Cancel response: ${res.statusCode} ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("Failed to cancel appointment");
    }
  }
}

/// ------------------ CUBITS ------------------
class DoctorAppointmentCubit extends Cubit<List<Appointment>> {
  final DoctorAppointmentRepository repository;
  DoctorAppointmentCubit(this.repository) : super([]);

  Future<void> loadAppointments() async {
    try {
      final appointments = await repository.getDoctorAppointments();
      print(appointments);
      emit(appointments);
    } catch (e) {
      print("Error loading appointments: $e");
      emit([]);
    }
  }

  Future<void> cancelAppointment(int id) async {
    try {
      await repository.cancelAppointment(id);
      final updated = state.where((a) => a.id != id).toList();
      emit(updated);
    } catch (e) {
      print("Error cancelling appointment: $e");
    }
  }
}

/// ------------------ UI ------------------
class DrAppo extends StatelessWidget {
  DrAppo({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create:
            (_) =>
                DoctorAppointmentCubit(DoctorAppointmentRepository())
                  ..loadAppointments(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeDr()),
                );
              },
            ),
            title: const Text(
              'Welcome Doctor!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: BlocBuilder<DoctorAppointmentCubit, List<Appointment>>(
                builder: (context, appointments) {
                  if (appointments.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.pink[50],
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.patientName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      appointment.patientEmail,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BlocProvider(
                                          create:
                                              (_) => MedicalRecordCubit(
                                                MedicalRecordRepository(),
                                              )..loadPatientRecords(
                                                appointment.patientId,
                                              ), // ✅ use patientId
                                          child: const MedicalRecordPage(),
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                "Medical record",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AddMedicalRecord(
                                          patientId: appointment.patientId,
                                          patientName: appointment.patientName,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                "Add medical record",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              appointment.date,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${appointment.startTime} - ${appointment.endTime}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () {
                                  context
                                      .read<DoctorAppointmentCubit>()
                                      .cancelAppointment(appointment.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDFE9FA),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
