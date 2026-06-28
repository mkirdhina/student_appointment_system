import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class AdminEditAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> adminUser;
  final Map<String, dynamic> appointment;

  const AdminEditAppointmentScreen({
    super.key,
    required this.adminUser,
    required this.appointment,
  });

  @override
  State<AdminEditAppointmentScreen> createState() =>
      _AdminEditAppointmentScreenState();
}

class _AdminEditAppointmentScreenState
    extends State<AdminEditAppointmentScreen> {
  String selectedStatus = 'Booked';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.appointment['status'].toString();
  }

  Future<void> updateAppointmentStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      final adminUserId = int.parse(widget.adminUser['user_id'].toString());
      final appointmentId = int.parse(
        widget.appointment['appointment_id'].toString(),
      );

      final result = await ApiService.adminUpdateAppointment(
        adminUserId,
        appointmentId,
        selectedStatus,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pop(context, result);
      } else {
        showMessage(result['message'] ?? 'Update failed.');
      }
    } catch (e) {
      showMessage('Update failed: $e');
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
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Update Appointment Status',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 16),

                      detailRow(
                        Icons.person_outline_rounded,
                        'Student',
                        appointment['student_name'].toString(),
                      ),
                      detailRow(
                        Icons.badge_outlined,
                        'Username',
                        appointment['student_username'].toString(),
                      ),
                      detailRow(
                        Icons.school_outlined,
                        'Lecturer',
                        appointment['lecturer_name'].toString(),
                      ),
                      detailRow(
                        Icons.calendar_today_rounded,
                        'Date',
                        appointment['appointment_date'].toString(),
                      ),
                      detailRow(
                        Icons.access_time_rounded,
                        'Time',
                        appointment['appointment_time'].toString(),
                      ),
                      detailRow(
                        Icons.meeting_room_outlined,
                        'Room',
                        appointment['room'].toString(),
                      ),
                      detailRow(
                        Icons.notes_rounded,
                        'Purpose',
                        appointment['purpose'].toString(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Appointment Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.edit_calendar_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'Booked', child: Text('Booked')),
                  DropdownMenuItem(
                    value: 'Cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateAppointmentStatus,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Save Status'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
