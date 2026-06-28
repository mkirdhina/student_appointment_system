import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login.jpg',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(
                    radius: 70,
                    backgroundColor: AppColors.softPink,
                    child: Icon(
                      Icons.school_rounded,
                      size: 78,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'EduMeet',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Student Appointment System',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textGrey),
              ),

              const SizedBox(height: 40),

              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
