import 'dart:convert';
import 'package:flutter_app/dr_appo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------ REPOSITORY ------------------
class MedicalRecordApiRepository {
  final String baseUrl = "http://10.0.2.2:8080/api";

  Future<void> addMedicalRecord({
    required int patientId,
    required String recordContent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) throw Exception("No auth token found");
    final date = DateTime.now().toString().split(' ')[0];
    print(date);
    print(recordContent);

    final res = await http.post(
      Uri.parse("$baseUrl/medical-records"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "patientId": patientId,
        "content": recordContent,
        "date": date,
      }),
    );

    print("Add medical record response: ${res.statusCode} ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add medical record");
    }
  }
}

/// ------------------ SCREEN ------------------
class AddMedicalRecordScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const AddMedicalRecordScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recordController = TextEditingController();
  final _repository = MedicalRecordApiRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _recordController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicalRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repository.addMedicalRecord(
        patientId: widget.patientId,
        recordContent: _recordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Navigate to DrAppo screen after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DrAppo()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrAppo()),
            );
          },
        ),
        title: const Text(
          'Add a medical record',
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
          child: Column(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _recordController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 18, height: 1),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medical record details';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter medical record details...',
                    hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicalRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                          : const Text(
                            'Save Medical Record',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

/// ------------------ MAIN FUNCTION ------------------
void main() {
  runApp(const AddMedicalRecord(patientId: 1, patientName: "John Doe"));
}

class AddMedicalRecord extends StatelessWidget {
  final int patientId;
  final String patientName;

  const AddMedicalRecord({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Record App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AddMedicalRecordScreen(
        patientId: patientId,
        patientName: patientName,
      ),
    );
  }
}
