import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class TestLocationScreen extends StatefulWidget {
  const TestLocationScreen({super.key});

  @override
  _TestLocationScreenState createState() => _TestLocationScreenState();
}

class _TestLocationScreenState extends State<TestLocationScreen> {
  loc.LocationData? _currentLocation;
  bool _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  String? _currentAddress;
  String? _street;
  String? _locality;

  Future<void> _checkLocationService() async {
    loc.Location location = loc.Location();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();
    if (_currentLocation != null) {
      _getAddressFromLatLng(
          _currentLocation!.latitude!, _currentLocation!.longitude!);
    }
    setState(() {});
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        _street = place.street;
        _locality = place.locality;
        _currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentLocation != null)
              Column(
                children: [
                  Text(
                    'Lat: ${_currentLocation!.latitude}, Lon: ${_currentLocation!.longitude}',
                  ),
                  if (_currentAddress != null)
                    Text(
                      'Address: $_currentAddress',
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: TextEditingController(text: _street),
                      decoration: const InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: TextEditingController(text: _locality),
                      decoration: const InputDecoration(
                        labelText: 'Locality',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: _checkLocationService,
              child: const Text('Check Location'),
            ),
          ],
        ),
      ),
    );
  }
}
