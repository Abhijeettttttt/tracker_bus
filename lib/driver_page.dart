import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DriverPage extends StatefulWidget {
  final String username;
  const DriverPage({super.key, required this.username});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  // Route and shift variables
  String selectedRoute = "Men's Hostel";
  bool isShiftActive = false;

  // Location and map variables
  final Location _location = Location();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(12.972060, 79.156578); // Default location
  String _locationData = 'Location not available';
  Timer? _locationUpdateTimer; // Timer to update location periodically

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Function to get and print the live location
  Future<void> _getLiveLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print('Location services are not enabled.');
        return;
      }
    }

    // Check location permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission denied');
        return;
      }
    }

    // Start periodic updates if the shift is active
    _startPeriodicLocationUpdates();
  }

  // Start a periodic task to update location in Firestore
  void _startPeriodicLocationUpdates() {
    _locationUpdateTimer?.cancel(); // Cancel any existing timer
    if (isShiftActive) {
      _locationUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
        LocationData locationData = await _location.getLocation();
        setState(() {
          _currentPosition =
              LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
          _locationData =
              'Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}';
              print(_locationData);
        });
        _updateDriverLocation();
      });
    }
  }

  // Update the driver location in Firestore
  void _updateDriverLocation() async {
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.username)
          .set({
        'username': widget.username,
        'location': GeoPoint(_currentPosition.latitude, _currentPosition.longitude),
        'isShiftActive': isShiftActive,
        'selectedRoute': selectedRoute,
      }, SetOptions(merge: true)); // Merge to avoid overwriting
      print("Driver location updated successfully");
    } catch (e) {
      print("Error updating driver location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Page')),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(title: Text('Home'), onTap: () => Navigator.pop(context)),
            DropdownButton<String>(
              value: selectedRoute,
              items: <String>["Men's Hostel", 'Academic Block']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRoute = newValue!;
                  _updateDriverLocation(); // Update the route in Firestore
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isShiftActive = !isShiftActive;
                  if (isShiftActive) {
                    _startPeriodicLocationUpdates();
                  } else {
                    _locationUpdateTimer?.cancel(); // Stop updates when the shift ends
                  }
                });
                _updateDriverLocation(); // Update shift status in Firestore
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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 18.0),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
