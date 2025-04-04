import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charms_hr/models/schedule.dart';

class Schedules with ChangeNotifier {
  static const _hostname = 'http://192.168.68.103:5002/cms/api/v1';
  //static const _hostname = 'http://10.0.2.2:5002/cms/api/v1';
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => [..._schedules];

  Future<void> fetchSchedules() async {
    try {
      final response = await http.get(Uri.parse('$_hostname/schedule/'));

      if (response.statusCode == 200) {
        final List<dynamic> scheduleData = json.decode(response.body);
        _schedules =
            scheduleData.map((data) => Schedule.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching schedules: $error');
      rethrow;
    }
  }

  Future<List<Schedule>> fetchSchedulesByStaffId(int staffId) async {
    try {
      final response =
          await http.get(Uri.parse('$_hostname/schedule/$staffId'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> scheduleData = json.decode(response.body);
        return scheduleData.map((data) => Schedule.fromJson(data)).toList();
      }
      throw Exception('Failed to fetch schedules for staff ID $staffId');
    } catch (error) {
      print('Error fetching schedules by staff ID: $error');
      rethrow;
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      final response = await http.post(
        Uri.parse('$_hostname/schedule/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_id': schedule.staffId,
          'work_date': schedule.workDate.toIso8601String(),
          'work_location': schedule.workLocation,
          'staff_type': schedule.staffType,
          'intern_slot': schedule.internSlot,
          'work_start_time': schedule.workStartTime,
          'work_end_time': schedule.workEndTime,
          'break_start_time': schedule.breakStartTime,
          'break_end_time': schedule.breakEndTime,
          'working_periods':
              schedule.workingPeriods?.map((p) => p.toJson()).toList(),
          'break_periods':
              schedule.breakPeriods?.map((p) => p.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        await fetchSchedules(); // Refresh the schedule list
        notifyListeners();
      } else {
        throw Exception('Failed to add schedule');
      }
    } catch (error) {
      print('Error adding schedule: $error');
      rethrow;
    }
  }

  Future<void> addSchedules(List<Schedule> schedules) async {
    try {
      final scheduleData = schedules
          .map((schedule) => {
                'staff_id': schedule.staffId,
                'work_date': schedule.workDate.toIso8601String().split('T')[0],
                'work_location': schedule.workLocation,
                'staff_type': schedule.staffType,
                'intern_slot': schedule.internSlot,
                'work_start_time': schedule.workStartTime?.replaceAll(' ', ''),
                'work_end_time': schedule.workEndTime?.replaceAll(' ', ''),
                'break_start_time':
                    schedule.breakStartTime?.replaceAll(' ', ''),
                'break_end_time': schedule.breakEndTime?.replaceAll(' ', '')
              })
          .toList();

      final response = await http.post(
        Uri.parse('$_hostname/schedule/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(scheduleData),
      );

      print('Request body: ${json.encode(scheduleData)}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Update local schedules list directly from response
        final responseData = json.decode(response.body);
        if (responseData['scheduleIds'] != null) {
          await fetchSchedules();
          notifyListeners();
        }
      } else {
        throw Exception('Failed to add schedules: ${response.body}');
      }
    } catch (error) {
      print('Error adding schedules: $error');
      rethrow;
    }
  }

  String _convertTo24Hour(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hours = int.parse(timeParts[0]);
    final minutes = timeParts[1];

    if (parts[1] == 'PM' && hours != 12) {
      hours += 12;
    } else if (parts[1] == 'AM' && hours == 12) {
      hours = 0;
    }

    return '${hours.toString().padLeft(2, '0')}:$minutes:00';
  }

  Future<void> updateSchedule(Schedule schedule) async {
  try {
    final Map<String, dynamic> updateData = {
      'staff_id': schedule.staffId,
      'work_date': schedule.workDate.toIso8601String().split('T')[0],
      'work_location': schedule.workLocation,
      'staff_type': schedule.staffType,
      'intern_slot': schedule.internSlot,
      'work_start_time': schedule.workStartTime,
      'work_end_time': schedule.workEndTime,
      'break_start_time': schedule.breakStartTime,
      'break_end_time': schedule.breakEndTime,
    };

    final response = await http.put(
      Uri.parse('$_hostname/schedule/${schedule.schedId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    print('Update response: ${response.body}');

    if (response.statusCode == 200) {
      await fetchSchedules();
      notifyListeners();
    } else {
      throw Exception('Failed to update schedule: ${response.body}');
    }
  } catch (error) {
    print('Error updating schedule: $error');
    rethrow;
  }
}

  Future<void> deleteSchedule(int schedId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_hostname/schedule/$schedId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _schedules.removeWhere((schedule) => schedule.schedId == schedId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete schedule');
      }
    } catch (error) {
      print('Error deleting schedule: $error');
      throw error;
    }
  }
}
