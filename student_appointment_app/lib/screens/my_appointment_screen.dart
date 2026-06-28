import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'edit_appointment_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const MyAppointmentsScreen({super.key, required this.user});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  bool isLoading = true;
  List appointments = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = int.parse(widget.user['user_id'].toString());
      final result = await ApiService.getMyAppointments(userId);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        message = result['message'] ?? '';

        if (result['success'] == true) {
          appointments = result['data'];
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        message = 'Connection failed: $e';
      });
    }
  }

  Future<void> goToEditScreen(Map<String, dynamic> appointment) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditAppointmentScreen(user: widget.user, appointment: appointment),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Appointment updated.')),
      );

      if (result['success'] == true) {
        loadAppointments();
      }
    }
  }

  Future<void> confirmCancel(Map appointment) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      await cancelAppointment(appointment);
    }
  }

  Future<void> cancelAppointment(Map appointment) async {
    try {
      final userId = int.parse(widget.user['user_id'].toString());
      final appointmentId = int.parse(appointment['appointment_id'].toString());

      final result = await ApiService.cancelAppointment(appointmentId, userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Appointment cancelled.')),
      );

      if (result['success'] == true) {
        loadAppointments();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    }
  }

  Color statusColor(String status) {
    if (status == 'Booked') {
      return const Color(0xFF2D1BFF);
    } else if (status == 'Cancelled') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FF),

      appBar: AppBar(
        title: const Text(
          'My Appointments',
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

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D1BFF)),
            )
          : appointments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message.isEmpty
                      ? 'You do not have any appointments yet.'
                      : message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadAppointments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = Map<String, dynamic>.from(
                    appointments[index],
                  );

                  final status = appointment['status'].toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFEDEBFF),
                                child: Icon(
                                  Icons.event_note_rounded,
                                  color: Color(0xFF2D1BFF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  appointment['lecturer_name'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor(status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor(status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          appointmentInfo(
                            Icons.calendar_today_rounded,
                            '${appointment['appointment_date']} at ${appointment['appointment_time']}',
                          ),
                          appointmentInfo(
                            Icons.meeting_room_outlined,
                            'Room: ${appointment['room']}',
                          ),
                          appointmentInfo(
                            Icons.notes_rounded,
                            'Purpose: ${appointment['purpose']}',
                          ),

                          const SizedBox(height: 14),

                          if (status != 'Cancelled') ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  goToEditScreen(appointment);
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit Appointment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D1BFF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  confirmCancel(appointment);
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel Appointment'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget appointmentInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF2D1BFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF555555),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
