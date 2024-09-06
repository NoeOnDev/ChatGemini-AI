// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              labelText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              labelText: 'Password',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomButton(
              text: 'Login',
              onPressed: () {
                print('Email: ${_emailController.text}');
                print('Password: ${_passwordController.text}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
