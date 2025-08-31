import 'dart:convert';
import 'package:caretrack/home_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookAppointmentPage extends StatefulWidget {
  final int doctorId;
  final double consultationFee;

  const BookAppointmentPage({
    Key? key,
    required this.doctorId,
    required this.consultationFee,
  }) : super(key: key);

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  int selectedDateIndex = 0;
  String selectedTime = "08:30 AM";
  bool isInPerson = true;
  bool isCashPayment = true;

  late List<Map<String, String>> dates;

  final List<String> timeSlots = [
    "08:00 AM",
    "08:30 AM",
    "09:00 AM",
    "09:30 AM",
  ];

  @override
  void initState() {
    super.initState();
    dates = _generateNextFiveDays();
  }

  List<Map<String, String>> _generateNextFiveDays() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      final day = now.add(Duration(days: index));
      final dayName = _getDayName(day.weekday);
      return {
        "day": dayName,
        "date": day.day.toString().padLeft(2, '0'),
        "fullDate": day.toIso8601String(),
      };
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  Future<void> _bookAppointment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      if (token == null) {
        throw Exception("No auth token found");
      }

      // Use the full date from the selected date entry
      final selectedDateString = dates[selectedDateIndex]["fullDate"]!;
      final appointmentDate = DateTime.parse(selectedDateString);
      final formattedDate =
          "${appointmentDate.year.toString().padLeft(4, '0')}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}";
      print(formattedDate);

      final url = Uri.parse("http://10.0.2.2:8080/api/appointments");
      final body = jsonEncode({
        "doctorId": widget.doctorId,
        "date": formattedDate,
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      print("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to HomeUser instead of Summary
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeUser()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Appointment booked successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to book appointment")));
      }
    } catch (e) {
      print("Error booking appointment: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _shareMedicalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString("auth_token");
      if (token == null) {
        throw Exception("No auth token found");
      }

      final url = Uri.parse(
        "http://10.0.2.2:8080/api/medical-records/share-all?doctorId=${widget.doctorId}",
      );
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Response: ${response.statusCode} ${response.body}");
    } catch (e) {
      print("Error sharing medical records: $e");
    }
  }

  int _parseHour(String time) {
    final parts = time.split(" ");
    final hm = parts[0].split(":");
    int hour = int.parse(hm[0]);
    if (parts[1] == "PM" && hour != 12) hour += 12;
    if (parts[1] == "AM" && hour == 12) hour = 0;
    return hour;
  }

  int _parseMinute(String time) {
    final parts = time.split(" ");
    return int.parse(parts[0].split(":")[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Date & Time",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Date Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Date",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "See Manual",
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      Container(
                        height: 80,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: Colors.black54,
                              ),
                              onPressed: () {},
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: dates.length,
                                itemBuilder: (context, index) {
                                  Map<String, String> date = dates[index];
                                  bool isSelected = index == selectedDateIndex;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDateIndex = index;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Color(0xFF2196F3)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            date["day"]!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            date["date"]!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: Colors.black54,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),
                      Text(
                        "Appointment Type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "In Person",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isCashPayment = !isCashPayment;
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isCashPayment
                                    ? Color(0xFF2196F3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isCashPayment
                                      ? Color(0xFF2196F3)
                                      : Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isCashPayment
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Cash",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _bookAppointment();
                    await _shareMedicalRecords();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppoDatetime extends StatelessWidget {
  final int doctorId;
  final double consultationFee;

  const AppoDatetime({
    Key? key,
    required this.doctorId,
    required this.consultationFee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: BookAppointmentPage(
        doctorId: doctorId,
        consultationFee: consultationFee,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(AppoDatetime(doctorId: 5, consultationFee: 100.0));
}
