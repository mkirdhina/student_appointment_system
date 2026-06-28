import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> appointment;

  const EditAppointmentScreen({
    super.key,
    required this.user,
    required this.appointment,
  });

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final purposeController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    purposeController.text = widget.appointment['purpose'].toString();
  }

  Future<void> updateAppointment() async {
    final purpose = purposeController.text.trim();

    if (purpose.isEmpty) {
      showMessage('Please enter appointment purpose.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final appointmentId = int.parse(
        widget.appointment['appointment_id'].toString(),
      );
      final userId = int.parse(widget.user['user_id'].toString());

      final result = await ApiService.updateAppointment(
        appointmentId,
        userId,
        purpose,
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
  void dispose() {
    purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Appointment',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Update Purpose',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: purposeController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter new purpose',
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateAppointment,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Save Changes'),
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
