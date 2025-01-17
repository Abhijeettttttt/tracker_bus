import 'package:flutter/material.dart';
import 'driver_page.dart';
import 'home_screen.dart';

class DriverLogin extends StatefulWidget {
  @override
  _DriverLogin createState() => _DriverLogin();
}

class _DriverLogin extends State<DriverLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? errorText;

  // Temporary login validation
  void validateLogin(BuildContext context) {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == 'driver' && password == 'password123') {
      // Navigate to DriverPage if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverPage()),
      );
    } else {
      // Show error if validation fails
      setState(() {
        errorText = 'Invalid username or password';
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
                    // Go back to the HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate login
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
