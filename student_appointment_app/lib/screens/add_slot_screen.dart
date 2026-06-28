import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2D1BFF), width: 1.6),
      ),
    );
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
      backgroundColor: const Color(0xFFFBF9FF),
      appBar: AppBar(
        title: const Text(
          'Add Consultation Slot',
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
            children: [
              const SizedBox(height: 25),

              const Icon(
                Icons.add_circle_outline_rounded,
                size: 90,
                color: Color(0xFF2D1BFF),
              ),

              const SizedBox(height: 18),

              const Text(
                'Create New Slot',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F2E),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add lecturer consultation availability',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: lecturerController,
                decoration: inputDecoration(
                  'Lecturer Name',
                  Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: dateController,
                decoration: inputDecoration(
                  'Date, example: 2026-07-05',
                  Icons.calendar_today_rounded,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: timeController,
                decoration: inputDecoration(
                  'Time, example: 12:00 PM',
                  Icons.access_time_rounded,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: roomController,
                decoration: inputDecoration(
                  'Room, example: Room 400',
                  Icons.meeting_room_outlined,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addSlot,
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
                          'Add Slot',
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
}
