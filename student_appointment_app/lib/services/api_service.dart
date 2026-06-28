import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator uses 10.0.2.2 to access XAMPP localhost on your Mac
  static const String baseUrl = 'http://10.0.2.2/student_appointment_api/api';

  static Future<Map<String, dynamic>> register(
    String name,
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSlots() async {
    final response = await http.get(Uri.parse('$baseUrl/get_slots.php'));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> bookAppointment(
    int userId,
    int slotId,
    String purpose,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book_appointment.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'slot_id': slotId,
        'purpose': purpose,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyAppointments(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_my_appointments.php?user_id=$userId'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateAppointment(
    int appointmentId,
    int userId,
    String purpose,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_appointment.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'appointment_id': appointmentId,
        'user_id': userId,
        'purpose': purpose,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cancelAppointment(
    int appointmentId,
    int userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cancel_appointment.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'appointment_id': appointmentId, 'user_id': userId}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addSlot(
    String lecturerName,
    String appointmentDate,
    String appointmentTime,
    String room,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_slot.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'lecturer_name': lecturerName,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'room': room,
      }),
    );

    return jsonDecode(response.body);
  }
}
