import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:send_sms/home_screen.dart';
import 'package:send_sms/message_provider.dart';
import 'package:intl/intl.dart';

// Main app entry point
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MessageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ডুয়াল সিম মেসেঞ্জার',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Provider for state management

// Contact model
class Contact {
  final String name;
  final String number;

  Contact({required this.name, required this.number});

  // Convert to JSON
  String toJson() {
    return '$name|||$number';
  }

  // Create from JSON
  factory Contact.fromJson(String json) {
    final parts = json.split('|||');
    return Contact(name: parts[0], number: parts[1]);
  }
}


