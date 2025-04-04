import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charms_hr/models/staff.dart';
import 'package:charms_hr/models/user.dart';

class Staffs with ChangeNotifier {
  static const _hostname = 'http://192.168.68.103:5002/cms/api/v1';
  //static const _hostname = 'http://10.0.2.2:5002/cms/api/v1';
  List<Staff> _staffList = [];

  // Getter for staff
  List<Staff> get staffList => [..._staffList];


  // Fetch Staff Data
  Future<void> fetchStaff(String hostname) async {
    try {
      final response = await http.get(Uri.parse('$_hostname/staff/'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final staffData = List<Map<String, dynamic>>.from(responseData['data']);
          _staffList = staffData.map((data) => Staff(
            staffId: data['id'] ?? 0,
            userId: data['userid'] ?? 0,
            username: data['username'] ?? '',
            email: data['email'] ?? '',
            usertype: data['usertype'] ?? 0,
            firstname: data['firstname'] ?? '',
            lastname: data['lastname'] ?? '',
            occupation: data['occupation'] ?? '',
            phone: data['phone'] ?? '',
            category: data['category'] ?? 1,
            nationality: data['nationality'] ?? '',
            religion: data['religion'] ?? '',
            maritalStatus: data['marital_status'] ?? 1,
            officePhone: data['office_phone'] ?? '',
            emergencyName: data['emergency_name'] ?? '',
            emergencyIc: data['emergency_ic'] ?? '',
            emergencyRelation: data['emergency_relation'] ?? '',
            emergencyGender: data['emergency_gender'] ?? 1,
            emergencyPhone: data['emergency_phone'] ?? '',
            idNum: data['idnum'],
            dob: data['dob'],
            address1: data['address1'],
            address2: data['address2'],
            city: data['city'],
            postcode: data['postcode'],
            state: data['state'],
            country: data['country'],
          )).toList();

          print('Fetched ${_staffList.length} staff members');
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error fetching staff: $error');
      rethrow;
    }
  }

  Future<Staff> fetchStaffById(int staffId) async {
  try {
    final response = await http.get(Uri.parse('$_hostname/staff/$staffId'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        final staffData = responseData['data'];
        return Staff(
          staffId: staffData['id'] ?? 0,
          userId: staffData['userid'] ?? 0,
          username: staffData['username'] ?? '',
          email: staffData['email'] ?? '',
          usertype: staffData['usertype'] ?? 0,
          firstname: staffData['firstname'] ?? '',
          lastname: staffData['lastname'] ?? '',
          occupation: staffData['occupation'] ?? '',
          phone: staffData['phone'] ?? '',
          category: staffData['category'] ?? 1,
          nationality: staffData['nationality'] ?? '',
          religion: staffData['religion'] ?? '',
          maritalStatus: staffData['marital_status'] ?? 1,
          officePhone: staffData['office_phone'] ?? '',
          emergencyName: staffData['emergency_name'] ?? '',
          emergencyIc: staffData['emergency_ic'] ?? '',
          emergencyRelation: staffData['emergency_relation'] ?? '',
          emergencyGender: staffData['emergency_gender'] ?? 1,
          emergencyPhone: staffData['emergency_phone'] ?? '',
          idNum: staffData['idnum'],
          dob: staffData['dob'],
          address1: staffData['address1'],
          address2: staffData['address2'],
          city: staffData['city'],
          postcode: staffData['postcode'],
          state: staffData['state'],
          country: staffData['country'],
        );
      }
    }
    throw Exception('Failed to fetch staff details');
  } catch (error) {
    print('Error fetching staff by ID: $error');
    rethrow;
  }
}

  List<Staff> getStaffByCategory(int category) {
    print('Filtering for category: $category');
    final filtered = _staffList.where((staff) => staff.category == category).toList();
    print('Found ${filtered.length} staff in category $category');
    return filtered;
  }

  Future<void> updateStaff(int staffId, Staff updatedStaff) async {
  try {
    final payload = {
      // Staff table fields
      'staff_data': {
        'nationality': updatedStaff.nationality,
        'religion': updatedStaff.religion,
        'marital_status': updatedStaff.maritalStatus,
        'office_phone': updatedStaff.officePhone,
        'emergency_name': updatedStaff.emergencyName,
        'emergency_ic': updatedStaff.emergencyIc,
        'emergency_relation': updatedStaff.emergencyRelation,
        'emergency_gender': updatedStaff.emergencyGender,
        'emergency_phone': updatedStaff.emergencyPhone
      },
      // Userdata table fields
      'user_data': {
        'phone': updatedStaff.phone,
        'address1': updatedStaff.address1,
        'address2': updatedStaff.address2,
        'city': updatedStaff.city,
        'postcode': updatedStaff.postcode,
        'state': updatedStaff.state,
        'country': updatedStaff.country
      },
      // Userlogin table fields
      'user_login': {
        'email': updatedStaff.email
      }
    };

    final response = await http.put(
      Uri.parse('$_hostname/staff/$staffId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final index = _staffList.indexWhere((staff) => staff.staffId == staffId);
      if (index != -1) {
        _staffList[index] = updatedStaff;
      }
      notifyListeners();
    } else {
      throw Exception('Failed to update staff details: ${response.body}');
    }
  } catch (error) {
    print('Error updating staff: $error');
    rethrow;
  }
}

Future<void> deleteStaff(int staffId) async {
  try {
    final response = await http.delete(Uri.parse('$_hostname/staff/$staffId'));
    if (response.statusCode == 200) {
      notifyListeners(); // Notify listeners to refresh the UI
    } else {
      throw Exception('Failed to delete staff');
    }
  } catch (error) {
    print('Error deleting staff: $error');
    rethrow;
  }
}
}

