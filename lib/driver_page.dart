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
  // For firebase database, don't change
  String selectedRoute = "Men's Hostel";
  bool isShiftActive = false;

  final Location _location = Location();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(12.972060, 79.156578); // Default location
  String _locationData = 'Location not available';

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
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

    // Get the current location
    LocationData locationData = await _location.getLocation();

    // Update the UI with location data
    setState(() {
      _currentPosition =
          LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
      _locationData =
          'Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}';
    });
    _updateDriverLocation();
    // Listen to location changes
    if (isShiftActive) {
      _location.onLocationChanged.listen((newLocation) {
        setState(() {
          _currentPosition =
              LatLng(newLocation.latitude ?? 0.0, newLocation.longitude ?? 0.0);
          _locationData =
              'Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}';
        });
        _updateDriverLocation();
      });
    }
  }

  // Update the driver location in Firestore
  void _updateDriverLocation() async {
    try {
      // Check if the document exists first
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.username)
          .get();

      if (snapshot.exists) {
        await FirebaseFirestore.instance
    .collection('drivers')
    .doc(widget.username)
    .set({
      'username': widget.username,
      'location': GeoPoint(_currentPosition.latitude, _currentPosition.longitude),
      'isShiftActive': isShiftActive,
      'selectedRoute': selectedRoute,
    }, SetOptions(merge: true))
    .then((_) {
      print("Document updated successfully!");
    }).catchError((e) {
      print("Error updating document: $e");
    });
 // Merge to avoid overwriting
        print("Driver location updated successfully");
      } else {
        print("Document does not exist. Check username or collection path.");
      }
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
