import 'package:flutter_app/User_login.dart';
import 'package:flutter_app/doctor_login.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/heart-2.png', width: 150),
              Text(
                'CareTrack',
                style: TextStyle(
                  color: const Color(0xFF223A6A),
                  fontSize: isSmallScreen ? 36 : 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Let\'s get started!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isSmallScreen ? 24 : 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Login to Stay healthy and fit',
                style: TextStyle(
                  color: const Color.fromARGB(127, 0, 0, 0),
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: isSmallScreen ? 250 : 350,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0080FF),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  },
                  child: Text(
                    'Patient',
                    style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: isSmallScreen ? 250 : 350,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0080FF),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DoctorLogin()),
                    );
                  },
                  child: Text(
                    'Doctor',
                    style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
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
