import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/claim.dart';

class Claims with ChangeNotifier {
  static const _hostname = 'http://192.168.68.103:5002/cms/api/v1';
  //static const _hostname = 'http://10.0.2.2:5002/cms/api/v1';
  List<Claim> _claims = [];

  List<Claim> get claims => [..._claims];

  Future<void> fetchClaims() async {
    try {
      final response = await http.get(Uri.parse('$_hostname/claim/'));
      print('Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> claimData = json.decode(response.body);
        _claims = claimData.map((data) => Claim.fromJson(data)).toList();
        notifyListeners();
      } else {
        print('Error fetching claims: ${response.body}');
      }
    } catch (error) {
      print('Exception fetching claims: $error');
      throw Exception('Failed to fetch claims: $error');
    }
  }

  Future<void> getClaimByStaffId(int staffId) async {
    try {
      final response = await http.get(Uri.parse('$_hostname/claim/staff/$staffId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> claimData = json.decode(response.body);
        _claims = claimData.map((data) => Claim.fromJson(data)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch claims');
      }
    } catch (error) {
      throw Exception('Error fetching claims: $error');
    }
  }

  Future<void> createClaim(Claim claim) async {
  final url = Uri.parse('$_hostname/claim/create');
  
  final Map<String, dynamic> payload = {
    'staff_id': claim.staffId,
    'claim_type': claim.claimType,
    'amount': claim.amount,
    'claim_date': claim.claimDate.toIso8601String(),
    'description': claim.description,
    'status': 'Pending',
    'proof_file_type': claim.proofFileType,
    'proof_file_name': claim.proofFileName,
    'proof_file': claim.proofFile != null ? base64Encode(claim.proofFile!) : null,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String()
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(payload),
  );

  if (response.statusCode == 201) {
    final responseData = json.decode(response.body);
    _claims.add(claim);
    notifyListeners();
  } else {
    throw Exception('Failed to create claim: ${response.body}');
  }
}

  Future<void> updateClaim(int claimId, String status) async {
  try {
    final response = await http.put(
      Uri.parse('$_hostname/claim/$claimId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': status,
        'updated_at': DateTime.now().toIso8601String()
      }),
    );

    if (response.statusCode == 200) {
      final index = _claims.indexWhere((claim) => claim.claimId == claimId);
      if (index != -1) {
        _claims[index] = _claims[index].copyWith(
          status: status,
          updatedAt: DateTime.now()
        );
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update claim: ${response.body}');
    }
  } catch (error) {
    throw Exception('Error updating claim: $error');
  }
}

  Future<void> deleteClaim(int claimId) async {
    try {
      final response = await http.delete(Uri.parse('$_hostname/claim/$claimId'));

      if (response.statusCode == 204) {
        _claims.removeWhere((claim) => claim.claimId == claimId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete claim');
      }
    } catch (error) {
      throw Exception('Error deleting claim: $error');
    }
  }
}