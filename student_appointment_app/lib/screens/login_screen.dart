import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    final username = userController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage('Please enter portal username and password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.login(username, password);

      if (!mounted) return;

      if (result['success'] == true) {
        final userData = Map<String, dynamic>.from(result['data']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: userData)),
        );
      } else {
        showMessage(result['message'] ?? 'Login failed.');
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
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/login.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.softPink,
                      child: Icon(
                        Icons.school_rounded,
                        size: 62,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  'EduMeet',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login to continue',
                  style: TextStyle(fontSize: 15, color: AppColors.textGrey),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: userController,
                  keyboardType: TextInputType.text,
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
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'No account? Register here.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
