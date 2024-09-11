import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  void _sendMessage(String number) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: number,
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'No se pudo enviar el mensaje a $number';
    }
  }

  void _makeCall(String number) async {
    final Uri telUri = Uri(
      scheme: 'tel',
      path: number,
    );

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw 'No se pudo realizar la llamada a $number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildContactItem(
            context,
            'Carlos Eduardo Gumeta Navarro',
            '221199',
            '9711315960',
          ),
          _buildContactItem(
            context,
            'Jesus Alejandro Guillen Luna',
            '221198',
            '9651052289',
          ),
          _buildContactItem(
            context,
            'Joel de Jesús López Ruíz',
            '221204',
            '9661130883',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, String name, String id, String phone) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('ID: $id'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () => _sendMessage(phone),
              tooltip: 'Enviar mensaje',
            ),
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _makeCall(phone),
              tooltip: 'Llamar',
            ),
          ],
        ),
      ),
    );
  }
}
