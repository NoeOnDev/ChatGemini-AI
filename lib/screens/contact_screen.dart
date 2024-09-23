import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool _hasCallSupport = false;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkCallSupport();
  }

  Future<void> _checkCallSupport() async {
    final bool result = await canLaunchUrl(Uri(scheme: 'tel', path: '123'));
    setState(() {
      _hasCallSupport = result;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'No se pudo hacer la llamada';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Llamada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'Ingresa el número de teléfono',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _hasCallSupport
                  ? () {
                      final String phone = _phoneController.text;
                      if (phone.isNotEmpty) {
                        _makePhoneCall(phone);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor, ingresa un número de teléfono'),
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(
                _hasCallSupport
                    ? 'Realizar llamada'
                    : 'Las llamadas no están soportadas',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
