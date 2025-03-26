import 'package:flutter/material.dart';

class TimePickerButton extends StatefulWidget {
  final TimeOfDay? initialTime;
  final Function(TimeOfDay)? onTimeSelected;
  final String buttonText;
  final Color buttonColor;
  final bool use24HourFormat;
  final TimePickerEntryMode initialEntryMode;

  const TimePickerButton({
    super.key,
    this.initialTime,
    this.onTimeSelected,
    this.buttonText = 'Select Time',
    this.buttonColor = Colors.teal,
    this.use24HourFormat = false,
    this.initialEntryMode = TimePickerEntryMode.dial,
  });

  @override
  State<TimePickerButton> createState() => _TimePickerButtonState();
}

class _TimePickerButtonState extends State<TimePickerButton> {
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      initialEntryMode: widget.initialEntryMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: widget.use24HourFormat),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
      if (widget.onTimeSelected != null) {
        widget.onTimeSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => _selectTime(context),
          child: Text(
            widget.buttonText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (selectedTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selected: ${selectedTime!.format(context)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

// Example usage:
void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: TimePickerButtonExample())),
    ),
  );
}

class TimePickerButtonExample extends StatelessWidget {
  const TimePickerButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TimePickerButton(
        initialTime: const TimeOfDay(hour: 12, minute: 0),
        onTimeSelected: (TimeOfDay time) {
          // Handle the selected time
          print('Selected time: ${time.format(context)}');
        },
        buttonText: 'Pick a Time',
        buttonColor: Colors.teal,
        use24HourFormat: false,
        initialEntryMode: TimePickerEntryMode.input,
      ),
    );
  }
}
