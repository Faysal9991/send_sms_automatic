// message_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class MessageProvider extends ChangeNotifier {
  final MethodChannel platform = MethodChannel('sms_channel');
  String _selectedSim = 'SIM 1';
  String _message = '';
  bool _isProcessing = false;
  List<Contact> _contacts = [];
  String? _selectedPhoneNumber;
  TimeOfDay? _selectedTime; 

  // Getters
  String get selectedSim => _selectedSim;
  String get message => _message;
  bool get isProcessing => _isProcessing;
  List<Contact> get contacts => _contacts;
  String? get selectedPhoneNumber => _selectedPhoneNumber;
TimeOfDay? get selectedTime => _selectedTime; // Getter for selectedTime
  MessageProvider() {
    _loadContacts();
  }

void setSelectedTime(TimeOfDay? time) {
    _selectedTime = time;
    notifyListeners();
  }


  int get simValue {
    switch (_selectedSim) {
      case 'SIM 1':
        return 1;
      case 'SIM 2':
        return 2;
      case 'Dual SIM':
        return 3;
      default:
        return 1;
    }
  }

  void setSim(String? newSim) {
    if (newSim != null && newSim != _selectedSim) {
      _selectedSim = newSim;
      notifyListeners();
    }
  }

  void setMessage(String text) {
    _message = text;
    notifyListeners();
  }

  List<String> saveContacts = [];
  Future<void> _loadContacts() async {
    if (await _requestContactsPermission()) {
      try {
        _contacts = await FlutterContacts.getContacts(withProperties: true);
        notifyListeners();
      } catch (e) {
        print('Error loading contacts: $e');
      }
    }
  }

  List<String> savedNumbers = [];

  Future<void> loadSavedNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? numbersJson = prefs.getString('saved_numbers');
    if (numbersJson != null) {
      savedNumbers = List<String>.from(jsonDecode(numbersJson));
      notifyListeners();
    }
  }

  Future<void> saveNumber(String phoneNumber) async {
    if (!savedNumbers.contains(phoneNumber)) {
      savedNumbers.add(phoneNumber);
      await _saveNumbersToPrefs();
      notifyListeners();
    }
  }

  Future<void> removeNumber(String phoneNumber) async {
    savedNumbers.remove(phoneNumber);
    await _saveNumbersToPrefs();
    notifyListeners();
  }

  Future<void> _saveNumbersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_numbers', jsonEncode(savedNumbers));
  }

  Future<bool> _requestContactsPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> _requestSmsPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> sendSms() async {
    await _requestSmsPermission();
  }

  Future<void> sendSmsUsingSim(
    BuildContext context,
    String phoneNumber,
    String message,
    int simSlot,
  ) async {
    if (!await _requestSmsPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SMS permission denied'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      if (simSlot == 3) {
        for (String number in savedNumbers) {
          await sendMessageChanel(number, message, 1);
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("SMS Sent Successfully from SIM 1"),
              backgroundColor: Colors.green,
            ),
          );
        }
       for (String number in savedNumbers) {
         await sendMessageChanel(number, message, 2);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("SMS Sent Successfully from SIM 2"), backgroundColor: Colors.green),
          );
        }
      }else{
           final String result = await platform.invokeMethod('sendSms', {
          'phoneNumber': phoneNumber,
          'message': message,
          'simSlot': simSlot,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS Sent Successfully from SIM $simSlot!'),
            backgroundColor: Colors.green,
          ),
        );
      }
   


   
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send SMS: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> sendMessageChanel(
    String phoneNumber,
    String message,
    int simSlot,
  ) async {
    return await platform.invokeMethod('sendSms', {
      'phoneNumber': phoneNumber,
      'message': message,
      'simSlot': simSlot - 1,
    });
  }
}
