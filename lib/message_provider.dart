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
  int _delayDuration = 0;
  int _smsQantity = 0;
  // Getters
  int get smsQantity => _smsQantity;
  int get delayDuration => _delayDuration;
  String get selectedSim => _selectedSim;
  String get message => _message;
  bool get isProcessing => _isProcessing;
  List<Contact> get contacts => _contacts;
  String? get selectedPhoneNumber => _selectedPhoneNumber;
  TimeOfDay? get selectedTime => _selectedTime; // Getter for selectedTime
  MessageProvider() {
    _loadContacts();
  }

  void changeDelayDuration(int newDelayDuration, BuildContext context) {
    _delayDuration = newDelayDuration;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected Time  $newDelayDuration'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // Allows custom positioning
        margin: EdgeInsets.only(
          top: 10, // Positions it near the top
          left: 10,
          right: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Optional: rounded corners
        ),
        duration: Duration(seconds: 3), // Optional: control how long it shows
      ),
    );
    notifyListeners();
  }

  void changeSMSQuantity(int newDelayDuration, BuildContext context) {
    _smsQantity = newDelayDuration;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('selected quantity  $newDelayDuration'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // Allows custom positioning
        margin: EdgeInsets.only(
          top: 10, // Positions it near the top
          left: 10,
          right: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Optional: rounded corners
        ),
        duration: Duration(seconds: 3), // Optional: control how long it shows
      ),
    );
    notifyListeners();
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
    // Request SMS permission
    var smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      smsStatus = await Permission.sms.request();
    }

    // Request phone state permission
    var phoneStatus = await Permission.phone.status;
    if (!phoneStatus.isGranted) {
      phoneStatus = await Permission.phone.request();
    }

    // Check additional permissions
    var contactStatus = await Permission.contacts.status;
    if (!contactStatus.isGranted) {
      contactStatus = await Permission.contacts.request();
    }

    // Return true only if all critical permissions are granted
    return smsStatus.isGranted &&
        phoneStatus.isGranted &&
        contactStatus.isGranted;
  }

  Future<void> sendSms() async {
    bool permissionsGranted = await _requestSmsPermission();
    if (!permissionsGranted) {
      // Handle permission denial
      print('One or more permissions were denied');
      // Optionally show a dialog or snackbar to user
    }
  }
  Future<void> sendSmsUsingSim(
    BuildContext context,
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
          for (int i = 0; i < _smsQantity; i++) {
            await sendMessageChanel(number, message, 1);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("SMS Sent Successfully from SIM 1"),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(Duration(seconds: _delayDuration));
          }
        }
        for (String number in savedNumbers) {
          for (int i = 0; i < _smsQantity; i++) {
            await sendMessageChanel(number, message, 2);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("SMS Sent Successfully from SIM 2"),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(Duration(seconds: _delayDuration));
          }
        }
      } else {
        for (String number in savedNumbers) {
          for (int i = 0; i < _smsQantity; i++) {
            await sendMessageChanel(number, message, simSlot);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("SMS Sent Successfully from SIM $simSlot"),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(Duration(seconds: _delayDuration));
          }
        }

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
      'simSlot': simSlot,
    });
  }
}
