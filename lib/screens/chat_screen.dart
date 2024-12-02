import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../sections/chat_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'qr_scan_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _selectedLanguage = 'Spanish';
  final _languages = ['Spanish', 'English'];
  final ValueNotifier<List<Content>> _chatsNotifier =
      ValueNotifier<List<Content>>([]);
  String? _locationContext;

  @override
  void initState() {
    super.initState();
    _getLocationContext();
  }

  Future<void> _getLocationContext() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    loc.LocationData currentLocation = await location.getLocation();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation.latitude!, currentLocation.longitude!);
    Placemark place = placemarks[0];
    setState(() {
      _locationContext =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    });
  }

  Future<void> _clearChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chats');
    _chatsNotifier.value = [];
  }

  Future<void> _showClearChatsDialog() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Clear Chats',
      desc: 'Are you sure you want to clear all chats?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScanScreen(),
          ),
        );

        if (result == 'delete') {
          _clearChats();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code')),
          );
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Chat-Gemini - $_selectedLanguage'),
        actions: [
          PopupMenuButton(
            initialValue: _selectedLanguage,
            onSelected: (value) => setState(() => _selectedLanguage = value),
            itemBuilder: (context) => _languages.map((language) {
              return PopupMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.language),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _showClearChatsDialog,
            tooltip: 'Clear Chats',
          ),
        ],
      ),
      body: SectionStreamChat(
        language: _selectedLanguage,
        chatsNotifier: _chatsNotifier,
        locationContext: _locationContext,
      ),
    );
  }
}