import 'package:flutter/material.dart';
import 'student_page.dart';
import 'driver_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedRole = 'Driver'; // Default value

  // Function to navigate to the selected page
  void navigateToPage(String role) {
    if (role == 'Driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: DropdownButton<String>(
          value: selectedRole,
          items: <String>['Driver', 'Student']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRole = newValue!;
            });
            navigateToPage(selectedRole);
          },
        ),
      ),
    );
  }
}
