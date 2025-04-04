import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Attendances with ChangeNotifier {
  final String baseUrl = 'http://192.168.68.103:5002/cms/api/v1';
  //final String baseUrl = 'http://10.0.2.2:5002/cms/api/v1';

  Future<bool> recordAttendance({
  required int staffId,
  required int scheduleId,
  required String imageBase64,
  required String clockInTime,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'staff_id': staffId,
        'schedule_id': scheduleId,
        'clock_in_image': imageBase64,
        'clock_in_time': clockInTime,
        'attendance_status': 2, // 2 for clocked in
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to record attendance: ${response.body}');
    }
    notifyListeners();
    return true;
  } catch (error) {
    throw error;
  }
}

Future<bool> checkAttendance({
  required int staffId,
  required int scheduleId,
}) async {
  try {
    final url = Uri.parse('$baseUrl/attendance/check?staff_id=$staffId&schedule_id=$scheduleId');
    print('Checking attendance at: $url');
    
    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final status = data['attendance_status'] == 2;
      print('Attendance status: $status');
      return status;
    }
    return false;
  } catch (error) {
    print('Error checking attendance: $error');
    return false;
  }
}

// Get all attendances
  Future<List<Map<String, dynamic>>> getAllAttendances() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/attendance'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      throw Exception('Failed to load attendances');
    } catch (error) {
      throw error;
    }
  }

  // Update attendance
  Future<bool> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/attendance/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      notifyListeners();
      return response.statusCode == 200;
    } catch (error) {
      throw error;
    }
  }

  // Delete attendance
  Future<bool> deleteAttendance(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/attendance/$id'),
      );
      notifyListeners();
      return response.statusCode == 204;
    } catch (error) {
      throw error;
    }
  }
}
