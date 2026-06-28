import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import 'available_slots_screen.dart';
import 'login_screen.dart';
import 'my_appointment_screen.dart';
import 'add_slot_screen.dart';
import 'admin_manage_appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  bool get isAdmin => user['role'] == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isAdmin ? 'Admin Dashboard' : 'Student Dashboard',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.textDark),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.softPink,
                      child: Icon(
                        isAdmin
                            ? Icons.admin_panel_settings_outlined
                            : Icons.person_outline_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      'Welcome, ${user['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      'Username: ${user['username']} • ${user['role']}',
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('View Available Slots'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailableSlotsScreen(user: user),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              if (!isAdmin)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list_alt_rounded),
                    label: const Text('My Appointments'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyAppointmentsScreen(user: user),
                        ),
                      );
                    },
                  ),
                ),

              if (isAdmin) ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Consultation Slot'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddSlotScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: const Text('Manage Appointments'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminManageAppointmentsScreen(user: user),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
