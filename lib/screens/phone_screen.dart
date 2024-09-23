import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  PhoneScreenState createState() => PhoneScreenState();
}

class PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not make the call';
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not send SMS';
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneExp = RegExp(r'^\d{8,10}$');
    return phoneExp.hasMatch(phoneNumber);
  }

  void _showInvalidNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Number'),
          content: const Text(
              'Please enter a valid phone number with 8 to 10 digits.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Screen'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Enter phone number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isValidPhoneNumber(_controller.text)) {
                      _makePhoneCall(_controller.text);
                    } else {
                      _showInvalidNumberDialog();
                    }
                  },
                  child: const Text('Call'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_isValidPhoneNumber(_controller.text)) {
                      _sendSms(_controller.text);
                    } else {
                      _showInvalidNumberDialog();
                    }
                  },
                  child: const Text('Send SMS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
