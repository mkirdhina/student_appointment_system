import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class AddSlotScreen extends StatefulWidget {
  const AddSlotScreen({super.key});

  @override
  State<AddSlotScreen> createState() => _AddSlotScreenState();
}

class _AddSlotScreenState extends State<AddSlotScreen> {
  final lecturerController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final roomController = TextEditingController();

  bool isLoading = false;

  Future<void> addSlot() async {
    final lecturerName = lecturerController.text.trim();
    final date = dateController.text.trim();
    final time = timeController.text.trim();
    final room = roomController.text.trim();

    if (lecturerName.isEmpty || date.isEmpty || time.isEmpty || room.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.addSlot(lecturerName, date, time, room);

      if (!mounted) return;

      showMessage(result['message'] ?? 'Slot added.');

      if (result['success'] == true) {
        lecturerController.clear();
        dateController.clear();
        timeController.clear();
        roomController.clear();
      }
    } catch (e) {
      showMessage('Failed to add slot: $e');
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
    lecturerController.dispose();
    dateController.dispose();
    timeController.dispose();
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Consultation Slot',
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
              const SizedBox(height: 25),

              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.softPink,
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 58,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Create New Slot',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add lecturer consultation availability',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textGrey),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: lecturerController,
                decoration: const InputDecoration(
                  labelText: 'Lecturer Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date, example: 2026-07-05',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time, example: 12:00 PM',
                  prefixIcon: Icon(Icons.access_time_rounded),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: 'Room, example: Room 400',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addSlot,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Add Slot'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
