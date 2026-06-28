import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';
import 'book_appointment_screen.dart';

class AvailableSlotsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AvailableSlotsScreen({super.key, required this.user});

  @override
  State<AvailableSlotsScreen> createState() => _AvailableSlotsScreenState();
}

class _AvailableSlotsScreenState extends State<AvailableSlotsScreen> {
  bool isLoading = true;
  List slots = [];
  String message = '';

  bool get isAdmin => widget.user['role'] == 'admin';

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  Future<void> loadSlots() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.getSlots();

      if (!mounted) return;

      setState(() {
        isLoading = false;
        message = result['message'] ?? '';

        if (result['success'] == true) {
          slots = result['data'];
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

  Future<void> goToBookingScreen(Map<String, dynamic> slot) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookAppointmentScreen(user: widget.user, slot: slot),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Booking completed.')),
      );

      if (result['success'] == true) {
        loadSlots();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isAdmin ? 'All Available Slots' : 'Available Slots',
          style: const TextStyle(
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : slots.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message.isEmpty ? 'No available slots found.' : message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadSlots,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = Map<String, dynamic>.from(slots[index]);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.softPink,
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          slot['lecturer_name'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${slot['appointment_date']} at ${slot['appointment_time']}\nRoom: ${slot['room']}',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              height: 1.4,
                            ),
                          ),
                        ),
                        trailing: isAdmin
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softPink,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Available',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  goToBookingScreen(slot);
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 42),
                                ),
                                child: const Text('Book'),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
