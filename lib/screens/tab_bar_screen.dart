import 'package:flutter/material.dart';
import 'contact_screen.dart';
import 'phone_screen.dart';

class TabBarScreen extends StatelessWidget {
  const TabBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contact & Phone'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Contact'),
              Tab(text: 'Phone'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ContactScreen(),
            PhoneScreen(),
          ],
        ),
      ),
    );
  }
}
