import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    final name = nameController.text.trim();
    final username = userController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._-]{4,20}$');

    if (!usernameRegex.hasMatch(username)) {
      showMessage(
        'Portal username must be 4-20 characters and cannot contain spaces.',
      );
      return;
    }

    if (password.length < 6) {
      showMessage('Portal password must be at least 6 characters.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.register(name, username, password);

      if (!mounted) return;

      showMessage(result['message'] ?? 'Registration completed.');

      if (result['success'] == true) {
        Navigator.pop(context);
      }
    } catch (e) {
      showMessage('Connection failed: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.softPink,
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 58,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Register to access the student portal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textGrey),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: 'Portal Username',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Portal Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
