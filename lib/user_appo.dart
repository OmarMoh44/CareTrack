import 'dart:convert';
import 'package:caretrack/home_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------ MODEL ------------------
class Appointment {
  final int id;
  final String doctorName;
  final String specialization;
  final String date;
  final String startTime;
  final String endTime;
  final String fee;
  final String city;
  final String street;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.fee,
    required this.city,
    required this.street,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json["id"] ?? 0,
      doctorName: json["doctorName"] ?? "Unknown Doctor",
      specialization: json["doctorSpeciality"] ?? "General",
      date: json["date"] ?? "N/A",
      startTime: json["doctorStartTime"] ?? "N/A",
      endTime: json["doctorEndTime"] ?? "N/A",
      fee: "${json["doctorConsultationFee"] ?? 500} LE",
      city: json["doctorCity"] ?? "Unknown City",
      street: json["doctorStreet"] ?? "Unknown Street",
    );
  }
}

/// ------------------ REPOSITORY ------------------
class UserAppointmentRepository {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<List<Appointment>> getUserAppointments() async {
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

    print("User appointments response: ${res.statusCode} ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        return [Appointment.fromJson(data)];
      }
    } else {
      throw Exception("Failed to load user appointments");
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

/// ------------------ CUBIT ------------------
class UserAppointmentCubit extends Cubit<List<Appointment>> {
  final UserAppointmentRepository repository;
  UserAppointmentCubit(this.repository) : super([]);

  Future<void> loadAppointments() async {
    try {
      final appointments = await repository.getUserAppointments();
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
class UserAppo extends StatelessWidget {
  UserAppo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) =>
            UserAppointmentCubit(UserAppointmentRepository())
              ..loadAppointments(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeUser()),
                );
              },
            ),
            title: const Text(
              'My Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(top: 0),
            child: BlocBuilder<UserAppointmentCubit, List<Appointment>>(
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appointment.specialization,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "4.7",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.black54,
                              ),
                              Text(
                                '${appointment.city}, ${appointment.street}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appointment.date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "${appointment.startTime} - ${appointment.endTime}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appointment.fee,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  context
                                      .read<UserAppointmentCubit>()
                                      .cancelAppointment(appointment.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDFEFFF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
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
    );
  }
}
