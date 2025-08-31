import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ------------------ MODELS ------------------
class MedicalRecord {
  final DateTime date;
  final String title;
  final String? doctorName;

  MedicalRecord({required this.date, required this.title, this.doctorName});

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      title: json['content'] ?? 'Medical Record',
      doctorName: json['doctor']?['fullName'],
    );
  }
}

// ------------------ REPOSITORY ------------------
class MedicalRecordRepository {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<List<MedicalRecord>> getPatientRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) throw Exception("No auth token found");

    final res = await http.get(
      Uri.parse("$baseUrl/medical-records/patient/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load patient records");
    }
  }

  Future<List<MedicalRecord>> getDoctorPatientRecords(int patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) throw Exception("No auth token found");

    final res = await http.get(
      Uri.parse("$baseUrl/medical-records/shared/doctor/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => MedicalRecord.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load doctor view records");
    }
  }
}

// ------------------ CUBIT ------------------
class MedicalRecordCubit extends Cubit<List<MedicalRecord>> {
  final MedicalRecordRepository repository;
  MedicalRecordCubit(this.repository) : super([]);

  Future<void> loadRecords() async {
    try {
      final records = await repository.getPatientRecords();
      emit(records);
    } catch (e) {
      emit([]);
    }
  }

  Future<void> loadPatientRecords(int patientId) async {
    try {
      final records = await repository.getDoctorPatientRecords(patientId);
      emit(records);
    } catch (e) {
      emit([]);
    }
  }
}

// ------------------ UI ------------------
class MedicalRecordPage extends StatelessWidget {
  final Widget? previousPage; // ✅ restored so profilepage doesn’t break

  const MedicalRecordPage({super.key, this.previousPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical Record")),
      body: BlocBuilder<MedicalRecordCubit, List<MedicalRecord>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (record.doctorName != null)
                        Text("Doctor: ${record.doctorName}"),
                      Text(
                        "${record.date.toLocal()}".split(' ')[0],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
