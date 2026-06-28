import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
      backgroundColor: const Color(0xFFFBF9FF),
      appBar: AppBar(
        title: const Text(
          'Edit Appointment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F1F2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBF9FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F1F2E),
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
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: purposeController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter new purpose',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF2D1BFF),
                      width: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D1BFF),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2D1BFF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$label: $value', style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
