import 'package:flutter/material.dart';
import 'driver_page.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverLogin extends StatefulWidget {
  const DriverLogin({super.key});

  @override
  _DriverLogin createState() => _DriverLogin();
}

class _DriverLogin extends State<DriverLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? errorText;

  // Temporary login validation
  void validateLogin(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Querying drivers collection for authentication
      final querySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If login is successful, navigate to DriverPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverPage(username: username)),
        );
      } else {
        setState(() {
          errorText = 'Invalid username or password';
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'An error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                errorText: errorText,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                errorText: errorText,
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    validateLogin(context);
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
