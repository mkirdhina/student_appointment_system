import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
      backgroundColor: const Color(0xFFFBF9FF),
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
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
                        'Slot Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: purposeController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Example: Consultation about final project',
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
                  onPressed: isLoading ? null : submitBooking,
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
                          'Confirm Booking',
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
