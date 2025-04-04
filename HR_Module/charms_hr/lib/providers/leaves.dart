import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/leave.dart';

class Leaves with ChangeNotifier {
  static const _hostname = 'http://192.168.68.103:5002/cms/api/v1';
  //static const _hostname = 'http://10.0.2.2:5002/cms/api/v1';
  List<Leave> _leaves = [];

  List<Leave> get leaves => [..._leaves];

  Future<void> fetchLeaves() async {
  try {
    final response = await http.get(Uri.parse('$_hostname/leave/'));
    print('Raw API Response: ${response.body}'); // Debugging

    if (response.statusCode == 200) {
      final List<dynamic> leaveData = json.decode(response.body);
      print('Parsed Leave Data: $leaveData'); // Debugging
      _leaves = leaveData.map((data) => Leave.fromJson(data)).toList();
      notifyListeners();
    } else {
      print('Error fetching leaves: ${response.body}');
    }
  } catch (error) {
    print('Exception fetching leaves: $error');
    throw Exception('Failed to fetch leaves: $error');
  }
}

  Future<Leave> getLeaveById(int leaveId) async {
    try {
      final response = await http.get(Uri.parse('$_hostname/leave/$leaveId'));

      if (response.statusCode == 200) {
        return Leave.fromJson(json.decode(response.body));
      }
      throw Exception('Leave not found');
    } catch (error) {
      throw Exception('Failed to fetch leave: $error');
    }
  }

  Future<void> getLeaveByStaffId({int? staffId}) async {
  try {
    final url = staffId != null 
        ? Uri.parse('$_hostname/leave/staff/$staffId')
        : Uri.parse('$_hostname/leave/');

    final response = await http.get(url);
    print('Raw response: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> && responseData.containsKey('leaves')) {
        // Handle response with "leaves" key
        final List<dynamic> leavesData = responseData['leaves'];
        _leaves = leavesData.map((item) => Leave.fromJson(item)).toList();
      } else if (responseData is List) {
        // Handle direct array response
        _leaves = responseData.map((item) => Leave.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected response format');
      }

      print('Processed leaves: $_leaves');
      notifyListeners();
    } else {
      throw Exception('Failed to fetch leaves: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching leaves: $error');
    throw Exception('Failed to fetch leaves: $error');
  }
}




  Future<void> createLeave(Leave leave) async {
    final url = Uri.parse('$_hostname/leave/create');

    final Map<String, dynamic> payload = {
      'staff_id': leave.staffId,
      'leave_type': leave.leaveType,
      'start_date': leave.startDate.toIso8601String(),
      'end_date': leave.endDate.toIso8601String(),
      'reason': leave.reason,
      'status': leave.status,
      'proof_file_type': leave.proofFileType
    };

    if (leave.proofFile != null) {
      payload['proof_file_name'] = leave.proofFileName;
      payload['proof_file'] = base64Encode(leave.proofFile!);
    }

    print('Sending payload: $payload');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception('Server error: ${response.body}');
    }
  }

  Future<void> updateLeave(Leave leave) async {
  try {
    // Only send the necessary data for status update
    final Map<String, dynamic> updateData = {
      'status': leave.status,
    };

    final response = await http.put(
      Uri.parse('$_hostname/leave/${leave.leaveId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    print('Update response: ${response.body}'); // Add this for debugging

    if (response.statusCode == 200) {
      await fetchLeaves();
    } else {
      throw Exception('Failed to update leave: ${response.statusCode}');
    }
  } catch (error) {
    print('Error updating leave: $error');
    throw Exception('Error updating leave: $error');
  }
}

  Future<void> deleteLeave(int leaveId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_hostname/leave/$leaveId'),
      );

      if (response.statusCode == 204) {
        _leaves.removeWhere((leave) => leave.leaveId == leaveId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete leave');
      }
    } catch (error) {
      throw Exception('Error deleting leave: $error');
    }
  }
}
