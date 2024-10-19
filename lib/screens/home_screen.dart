import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: Noé Alejandro Rodríguez Moto',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Universidad: Universidad Politécnica de Chiapas',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Carrera: Ingeniería en Desarrollo Software',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
