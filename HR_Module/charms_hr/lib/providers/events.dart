import 'dart:async';
import 'dart:convert';

import 'package:charms_hr/models/event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Events with ChangeNotifier {
  List<Event> _eventslist = [];
  late Map<DateTime, List<Event2>> _kEventSource = {};

  List<Event> get eventlist {
    return [..._eventslist];
  }

  Map<DateTime, List<Event2>> get kEventSource {
    return {..._kEventSource};
  }

  // Event findById(String id) {
  //   return _eventslist.firstWhere((Event) => Event.id == id);
  // }

  Future<void> createEvent(String hostname, Event newEvent, int userid) async {
    final url = '${hostname}event/create';

    await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      encoding: Encoding.getByName('utf-8'),
      body: jsonEncode({
        'title': newEvent.title,
        'startdate': newEvent.startdate,
        'enddate': newEvent.enddate,
        'createdby': userid,
        'eventtype': newEvent.eventtype,
      }),
    );

    final newEvents = Event(
      id: '',
      title: newEvent.title,
      startdate: newEvent.startdate,
      enddate: newEvent.enddate,
      eventtype: newEvent.eventtype,
    );
    _eventslist.add(newEvents);
    notifyListeners();
  }

  Future<void> fetchEventGeneral(String hostname) async {
    final url = '${hostname}event/';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedEvent = jsonDecode(response.body);
      final List<Event> loadedEvent = [];
      extractedEvent.forEach((eventData) {
        loadedEvent.add(Event(
          id: eventData['id'].toString(),
          title: eventData['title'],
          startdate: eventData['startdate'],
          enddate: eventData['enddate'],
          // startdate2: eventData['startdate2'] ?? '',
          // enddate2: eventData['enddate2'] ?? '',
          // status: int.parse(eventData['status']),
          // createdby: int.parse(eventData['createdby']),
          // approve1: int.parse(eventData['approve1']),
          // approve2: int.parse(eventData['approve2']),
          // eventtype: int.parse(eventData['eventtype']),
        ));
      });
      _eventslist = loadedEvent;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchEventAdmin(String hostname) async {
    final url = '${hostname}event/admin';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedEvent = jsonDecode(response.body);
      final List<Event> loadedEvent = [];
      extractedEvent.forEach((eventData) {
        loadedEvent.add(Event(
          id: eventData['id'].toString(),
          title: eventData['title'],
          startdate: eventData['startdate'],
          enddate: eventData['enddate'],
          // startdate2: eventData['startdate2'] ?? '',
          // enddate2: eventData['enddate2'] ?? '',
          // status: int.parse(eventData['status']),
          // createdby: int.parse(eventData['createdby']),
          // approve1: int.parse(eventData['approve1']),
          // approve2: int.parse(eventData['approve2']),
          // eventtype: int.parse(eventData['eventtype']),
        ));
      });
      _eventslist = loadedEvent;
      // _kEventSource = {
      //   for (var item in loadedEvent)
      //     DateTime.utc(
      //         item.startdate.year, item.startdate.month, item.startdate.day): [
      //       item
      //     ]
      // };
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future fetchCalendarEvent(String hostname) async {
    final url = '${hostname}event/';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedEvent = jsonDecode(response.body);
      final List<Event2> calendarevent = [];
      extractedEvent.forEach((eventData) {
        calendarevent.add(Event2(
            title: eventData['title'],
            startdate: DateTime.parse(eventData['startdate']),
            enddate: DateTime.parse(eventData['enddate']),
            id: eventData['id']));
      });
      _kEventSource = {
        for (var item in calendarevent)
          DateTime.utc(
              item.startdate.year, item.startdate.month, item.startdate.day): [
            item
          ]
      };

      // print(_kEventSource);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
