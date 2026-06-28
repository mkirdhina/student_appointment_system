import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> slot;

  const BookAppointmentScreen({
    super.key,
    required this.user,
    required this.slot,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final purposeController = TextEditingController();
  bool isLoading = false;

  Future<void> submitBooking() async {
    final purpose = purposeController.text.trim();

    if (purpose.isEmpty) {
      showMessage('Please enter appointment purpose.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userId = int.parse(widget.user['user_id'].toString());
      final slotId = int.parse(widget.slot['slot_id'].toString());

      final result = await ApiService.bookAppointment(userId, slotId, purpose);

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pop(context, result);
      } else {
        showMessage(result['message'] ?? 'Booking failed.');
      }
    } catch (e) {
      showMessage('Booking failed: $e');
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
    final slot = widget.slot;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
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
                        'Slot Details',
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
                        slot['lecturer_name'].toString(),
                      ),
                      detailRow(
                        Icons.calendar_today_rounded,
                        'Date',
                        slot['appointment_date'].toString(),
                      ),
                      detailRow(
                        Icons.access_time_rounded,
                        'Time',
                        slot['appointment_time'].toString(),
                      ),
                      detailRow(
                        Icons.meeting_room_outlined,
                        'Room',
                        slot['room'].toString(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Appointment Purpose',
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
                  hintText: 'Example: Consultation about final project',
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitBooking,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Confirm Booking'),
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
