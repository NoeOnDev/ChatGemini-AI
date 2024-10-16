import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('Posts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/posts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.gif),
              title: const Text('GIFs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/gifts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Contact'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: 100.0),
          child: Text(
            '¡Welcome to my humble application!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
