import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const StudentAppointmentApp());
}

class StudentAppointmentApp extends StatelessWidget {
  const StudentAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Appointment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 4, 0, 255),
        ),
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}
