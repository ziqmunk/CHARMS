import 'dart:convert';

import 'package:charms_hr/models/indemnity.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Indemnitites with ChangeNotifier {
  List<Indemnity> _indemlist = [];

  List<Indemnity> get indemlist {
    return [..._indemlist];
  }

  Indemnity findById(String id) {
    return _indemlist.firstWhere((item) => item.id == id);
  }

  Future<void> fetchIndemnitiesbyStatus(String hostname, int status) async {
    final url = '${hostname}indemnity/$status';

    try {
      final response = await http.get(Uri.parse(url));
      final extactedData = jsonDecode(response.body);
      final List<Indemnity> loadedIndem = [];
      extactedData.forEach((indemData) {
        loadedIndem.add(Indemnity(
          id: indemData['id'],
          indemitems: indemData['indemitem'],
          type: indemData['type'],
          status: indemData['status'],
        ));
      });
      _indemlist = loadedIndem;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchIndemnitiesbyType(String hostname, int type) async {
    final url = '${hostname}indemnity/bytype/$type';

    try {
      final response = await http.get(Uri.parse(url));
      final extactedData = jsonDecode(response.body);
      final List<Indemnity> loadedIndem = [];
      extactedData.forEach((indemData) {
        loadedIndem.add(Indemnity(
          id: indemData['id'],
          indemitems: indemData['indemitem'],
          type: indemData['type'],
          status: indemData['status'],
        ));
      });
      _indemlist = loadedIndem;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> createIndemnity(
      String hostname, Indemnity newIndem, int userid) async {
    final url = '${hostname}indemnity/create';

    try {
      await http.post(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        encoding: Encoding.getByName('utf-8'),
        body: jsonEncode({
          'indemitem': newIndem.indemitems,
          'type': newIndem.type,
          'createdby': userid,
        }),
      );

      final newIndemnity = Indemnity(
        id: 0,
        indemitems: newIndem.indemitems,
        type: newIndem.type,
      );
      _indemlist.add(newIndemnity);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
