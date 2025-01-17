import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_01/home_screen.dart';

class DriverPage extends StatefulWidget {
  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  Set<Marker> _markers = {};
  String selectedRoute = "Men's Hostel"; // Default value
  bool isShiftActive = false;

  // Function to navigate to the selected page
  void navigateToPage(String route) {
    if (route == "Men's Hostel") {
      //Route to mens hostel shuttle logic
    } else {
      //route to academic blocks shuttle logic
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('driver1'),
          position: LatLng(12.972060, 79.156578), // Driver's current position
          infoWindow: InfoWindow(title: 'Driver Location'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Other Option 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            DropdownButton<String>(
              value: selectedRoute,
              items: <String>["Men's Hostel", 'Academic Block']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRoute = newValue!;
                  print(selectedRoute);
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isShiftActive = !isShiftActive; // Toggle the shift state
                });
                print(isShiftActive ? "Shift Started" : "Shift Ended");
              },
              child: Text(isShiftActive ? 'End Shift' : 'Start Shift'),
            ),
            Spacer(),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(12.972060, 79.156578),
                zoom: 18,
              ),
              markers: _markers,
              onMapCreated: _onMapCreated,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Bus Location: Men\'s Hostel to Academic Block',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            'Estimated Time of Arrival: 15 minutes',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
