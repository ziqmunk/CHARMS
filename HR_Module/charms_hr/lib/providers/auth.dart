import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/staff.dart';
 
class Auth with ChangeNotifier {
  DateTime? lastLoginTime;
  String? _token;
  DateTime _expiryDate = DateTime.now();
  int _usertype = 2;
  Timer _authTimer = Timer(
    const Duration(hours: 0),
    () {},
  );
  String _username = '';

  static const String _hostname = 'http://192.168.68.103:5002/cms/api/v1/';
  //static const String _hostname = 'http://10.0.2.2:5002/cms/api/v1/';
  //static const String _hostname = 'http://172.17.67.109:5000/cms/api/v1/';
  // static const String _hostname = 'http://192.168.1.109:5000/cms/api/v1/';
  // static const String _hostname = 'http://192.168.1.112:5000/cms/api/v1/';

  String get username {
    return _username;

    // return null;
  }

  String get hostname {
    return _hostname;
  }

  bool get isAuth {
    return token != null;
  }

  String? get token {
    return _token;
  }

  int get usertype {
    return _usertype;
  }

  Future<int> authenticate(String username, String passkey) async {
    const url = '${_hostname}user/auth';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'passkey': passkey,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _token = responseData['data'][0]['userid'].toString();
        _username = responseData['data'][0]['username'];
        _usertype = responseData['data'][0]['usertype'];
        _expiryDate = DateTime.now().add(const Duration(hours: 3));
        lastLoginTime = DateTime.now();

        // Store user data
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'usertype': _usertype,
          'username': _username,
          'expiryDate': _expiryDate.toIso8601String(),
          'lastLoginTime': lastLoginTime?.toIso8601String(),
        });
        prefs.setString('userData', userData);

        _autoLogout();
        notifyListeners();
        return _usertype;
      }
      throw Exception('Authentication failed');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> register(User newUser) async {
    const url = '${_hostname}user/create';
    await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      encoding: Encoding.getByName('utf-8'),
      body: jsonEncode({
        'firstname': newUser.firstname,
        'lastname': newUser.lastname,
        'phone': newUser.phone,
        'dob': newUser.dob,
        'address1': newUser.address1,
        'address2': newUser.address2,
        'city': newUser.city,
        'postcode': newUser.postcode,
        'state': newUser.state,
        'country': newUser.country,
        'occupation': newUser.occupation,
        'email': newUser.email,
        'username': newUser.username,
        'passkey': newUser.password,
        'usertype': newUser.usertype,
        'gender': newUser.gender,
        'staff_id': newUser.staff_id,
        'nationality': newUser.nationality,
        'religion': newUser.religion,
        'marital_status': newUser.marital_status,
        'office_phone': newUser.office_phone
      }),
    );

    // final prefs = await SharedPreferences.getInstance();
    // final String tempToken = '${newUser.usertype}/${newUser.username}';
    // final userData = json.encode({
    //   'token': tempToken,
    //   'usertype': newUser.usertype,
    //   'username': newUser.username,
    // 'expiryDate': _expiryDate.toIso8601String(),
    // });
    // prefs.setString('userData', userData);
    // final newStaff = User(
    //   fullname: User.fullname,
    //   email: User.email,
    //   phone: User.phone,
    //   department: User.department,
    //   section: User.section,
    //   salary: User.salary,
    //   username: User.username,
    //   userpassword: User.userpassword,
    //   usertype: User.usertype,
    //   userid: authUserId,
    //   id: '',
    // );
    // _userList.add(newStaff);
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedData =
        json.decode(prefs.getString('userData')!) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedData['expiryDate'].toString());

    if (expiryDate.isAfter(DateTime.now())) {
      return false;
    }

    _token = extractedData['id'].toString();
    _usertype = int.parse(extractedData['usertype'].toString());
    _username = extractedData['username'].toString();
    lastLoginTime = DateTime.now();
    // _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _usertype = 0;
    _username = '';
    _expiryDate = DateTime.now();
    if (_authTimer != Timer(Duration.zero, () {})) {
      _authTimer.cancel();
      _authTimer = Timer(Duration.zero, () {});
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != Timer(Duration.zero, () {})) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inHours;
    _authTimer = Timer(Duration(hours: timeToExpiry), logout);
  }

  Future<void> registerStaff(Map<String, String> staffData) async {
    const url = '${_hostname}user/create';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        encoding: Encoding.getByName('utf-8'),
        body: jsonEncode({
          'firstname': staffData['firstname'],
          'lastname': staffData['lastname'],
          'idnum': staffData['idnum'],
          'phone': staffData['phone'],
          'dob': staffData['dob'],
          'address1': staffData['address1'],
          'address2': staffData['address2'],
          'city': staffData['city'],
          'postcode': staffData['postcode'],
          'state': staffData['state'],
          'country': staffData['country'],
          'occupation': staffData['occupation'],
          'email': staffData['email'],
          'username': staffData['username'],
          'passkey': staffData['password'],
          'usertype': staffData['role'],
          'gender': staffData['gender'],
          'filename': staffData['filename'],
          'staff_id': staffData['staff_id'],
          'nationality': staffData['nationality'],
          'religion': staffData['religion'],
          'marital_status': staffData['marital_status'],
          'office_phone': staffData['office_phone'],
          'emergency_name': staffData['emergency_name'],
          'emergency_ic': staffData['emergency_ic'],
          'emergency_relation': staffData['emergency_relation'],
          'emergency_gender': staffData['emergency_gender'],
          'emergency_phone': staffData['emergency_phone'],
          'category': staffData['category'],
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success, the user was created
        print('User created successfully: ${response.body}');
        notifyListeners();
      } else {
        // Server responded with an error or different status code
        print('Failed to register staff: ${response.body}');
        throw Exception('Registration failed. Response: ${response.body}');
      }
    } catch (error) {
      print('Error during registration: $error');
      rethrow;
    }
  }
}
