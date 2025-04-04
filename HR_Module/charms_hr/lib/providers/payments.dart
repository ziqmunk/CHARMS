import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';

class Payments with ChangeNotifier {
  static const _hostname = 'http://192.168.68.103:5002/cms/api/v1';
  //static const _hostname = 'http://10.0.2.2:5002/cms/api/v1';
  List<Payment> _payments = [];

  List<Payment> get payments => [..._payments];

  Future<void> fetchPayments() async {
    try {
      final response = await http.get(Uri.parse('$_hostname/payment/'));
      
      if (response.statusCode == 200) {
        final List<dynamic> paymentData = json.decode(response.body);
        _payments = paymentData.map((data) => Payment.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Failed to fetch payments: $error');
    }
  }

  Future<void> fetchPaymentsByMonth(int year, int month) async {
  try {
    // Get all payments since the data is there
    final response = await http.get(Uri.parse('$_hostname/payment/'));
    print('Fetching all payments');
    
    if (response.statusCode == 200) {
      final List<dynamic> paymentData = json.decode(response.body);
      _payments = paymentData.map((data) => Payment.fromJson(data)).toList();
      print('Total payments fetched: ${_payments.length}');
      notifyListeners();
    }
  } catch (error) {
    print('Error in fetchPaymentsByMonth: $error');
    throw Exception('Failed to fetch payments: $error');
  }
}


  Future<Payment> getPaymentById(int paymentId) async {
    try {
      final response = await http.get(Uri.parse('$_hostname/payment/$paymentId'));
      
      if (response.statusCode == 200) {
        return Payment.fromJson(json.decode(response.body));
      }
      throw Exception('Payment not found');
    } catch (error) {
      throw Exception('Failed to fetch payment: $error');
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      final response = await http.post(
        Uri.parse('$_hostname/payment/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchPayments();
      } else {
        throw Exception('Failed to add payment');
      }
    } catch (error) {
      throw Exception('Error adding payment: $error');
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      final response = await http.put(
        Uri.parse('$_hostname/payment/${payment.paymentId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchPayments();
      } else {
        throw Exception('Failed to update payment');
      }
    } catch (error) {
      throw Exception('Error updating payment: $error');
    }
  }

  Future<void> deletePayment(int paymentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_hostname/payment/$paymentId'),
      );

      if (response.statusCode == 204) {
        _payments.removeWhere((payment) => payment.paymentId == paymentId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete payment');
      }
    } catch (error) {
      throw Exception('Error deleting payment: $error');
    }
  }
}