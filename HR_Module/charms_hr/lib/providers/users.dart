import 'dart:convert';
import 'package:charms_hr/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  List<User> _userlist = [];

  List<User> get userlist => [..._userlist];

  User findUserById(String id) {
    return _userlist.firstWhere((user) => user.id == id);
  }

  Future<void> fetchUsers(String hostname) async {
  final url = '${hostname}user/';

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = jsonDecode(response.body);
    final List<dynamic> extractedUsers = extractedData['data'];
    final List<User> loadedUsers = [];

    for (var userData in extractedUsers) {
      loadedUsers.add(User(
        id: userData['id'].toString(),
        firstname: userData['firstname'] ?? '',
        lastname: userData['lastname'] ?? '',
        phone: userData['phone'] ?? '',
        email: userData['email'] ?? '',
        dob: userData['dob'] ?? '',
        address1: userData['address1'] ?? '',
        address2: userData['address2'],
        city: userData['city'] ?? '',
        postcode: userData['postcode'] ?? 0,
        state: userData['state'] ?? '',
        country: userData['country'] ?? '',
        occupation: userData['occupation'] ?? '',
        username: userData['username'] ?? '',
        password: userData['passkey'] ?? '',
        usertype: userData['usertype'] ?? 0,
        gender: userData['gender'] ?? 1,
      ));
    }

    _userlist = loadedUsers;
    notifyListeners();
  } catch (error) {
    rethrow;
  }
}

  Future<void> fetchUserByUsername(String hostname, String username) async {
    final url = '${hostname}user/data/$username';
    
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = jsonDecode(response.body);
      
      if (extractedData['success']) {
        final userData = extractedData['data'][0];
        final loadedUser = User(
          id: userData['id'].toString(),
          firstname: userData['firstname'] ?? '',
          lastname: userData['lastname'] ?? '',
          phone: userData['phone'] ?? '',
          email: userData['email'] ?? '',
          dob: userData['dob'] ?? '',
          address1: userData['address1'] ?? '',
          address2: userData['address2'],
          city: userData['city'] ?? '',
          postcode: userData['postcode'] ?? 0,
          state: userData['state'] ?? '',
          country: userData['country'] ?? '',
          occupation: userData['occupation'] ?? '',
          username: userData['username'] ?? '',
          password: userData['passkey'] ?? '',
          usertype: userData['usertype'] ?? 0,
          gender: userData['gender'] ?? 1,
          staff_id: userData['staff_id'],
          category: userData['category'],
          nationality: userData['nationality'],
          religion: userData['religion'],
          marital_status: userData['marital_status'],
          office_phone: userData['office_phone'],
          emergency_name: userData['emergency_name'],
          emergency_ic: userData['emergency_ic'],
          emergency_relation: userData['emergency_relation'],
          emergency_gender: userData['emergency_gender'],
          emergency_phone: userData['emergency_phone'],
        );
        _userlist = [loadedUser];
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<User>> fetchAdminUsers(String hostname) async {
  final url = '${hostname}user/';
  
  try {
    final response = await http.get(Uri.parse(url));
    final extractedUsers = jsonDecode(response.body)['data'];
    final List<User> adminUsers = [];

    for (var userData in extractedUsers) {
      // Filter for admin users (usertype 6)
      if (userData['usertype'] == 6) {
        adminUsers.add(User(
          id: userData['id'].toString(),
          firstname: userData['firstname'] ?? '',
          lastname: userData['lastname'] ?? '',
          phone: userData['phone'] ?? '',
          email: userData['email'] ?? '',
          dob: userData['dob'] ?? '',
          address1: userData['address1'] ?? '',
          address2: userData['address2'],
          city: userData['city'] ?? '',
          postcode: userData['postcode'] ?? 0,
          state: userData['state'] ?? '',
          country: userData['country'] ?? '',
          occupation: userData['occupation'] ?? '',
          username: userData['username'] ?? '',
          password: userData['passkey'] ?? '',
          usertype: userData['usertype'] ?? 0,
          gender: userData['gender'] ?? 1,
          staff_id: userData['staff_id'],
          category: userData['category'],
          nationality: userData['nationality'],
          religion: userData['religion'],
          marital_status: userData['marital_status'],
          office_phone: userData['office_phone'],
          emergency_name: userData['emergency_name'],
          emergency_ic: userData['emergency_ic'],
          emergency_relation: userData['emergency_relation'],
          emergency_gender: userData['emergency_gender'],
          emergency_phone: userData['emergency_phone'],
        ));
      }
    }
    return adminUsers;
  } catch (error) {
    throw error;
  }
}

  Future<void> updateUser(String hostname, String userId, Map<String, dynamic> userData) async {
  final url = '${hostname}user/$userId';
  
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
    
    // Refresh the user data after successful update
    await fetchUserByUsername(hostname, _userlist.first.username);
  } catch (error) {
    rethrow;
  }
}
}
