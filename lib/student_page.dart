import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final Location _location = Location();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _initialPosition = LatLng(12.9716, 79.1591); // VIT Vellore location
  bool _isCameraMovedManually = false; // Prevent auto-panning on manual map movement

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenToDriverChanges(); // Real-time Firestore updates
  }

  // Get the user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await _location.getLocation();
    setState(() {
      _initialPosition = LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    });

    _location.onLocationChanged.listen((newLocation) {
      if (!mounted || _isCameraMovedManually) return; // Skip if user moved the camera manually
      setState(() {
        _initialPosition = LatLng(newLocation.latitude ?? 0.0, newLocation.longitude ?? 0.0);
      });
    });
  }

  // Listen for real-time updates from Firestore
  void _listenToDriverChanges() {
    FirebaseFirestore.instance.collection('drivers').snapshots().listen((snapshot) {
      Set<Marker> updatedMarkers = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        bool isShiftActive = data['isShiftActive'] ?? false;

        if (isShiftActive) {
          LatLng driverLocation = LatLng(
            data['location'].latitude,
            data['location'].longitude,
          );
          String route = data['selectedRoute'];
          double rotation = data['rotation'] ?? 0.0; // Direction of movement (degrees)

          // Choose marker color based on route
          final hue = route == "Men's Hostel" ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange;

          updatedMarkers.add(Marker(
            markerId: MarkerId(doc.id),
            position: driverLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(hue), // Colored car marker
            infoWindow: InfoWindow(
              title: 'Driver: ${doc.id}',
              snippet: 'Route: $route',
            ),
            rotation: rotation, // Rotate marker to match the direction
          ));
        }
      }

      if (mounted) {
        setState(() {
          _markers = updatedMarkers;
        });
      }
    });
  }

  // Initialize map controller
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Page'),
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
        initialCameraPosition: CameraPosition(
          target: _initialPosition, // Starts at VIT Vellore
          zoom: 18.0,
        ),
        onMapCreated: _onMapCreated,
        markers: _markers,
        myLocationEnabled: true, // Show blue dot for user's location
        myLocationButtonEnabled: true,
        onCameraMove: (_) {
          // Detect manual camera movement
          setState(() {
            _isCameraMovedManually = true;
          });
        },
      ),
    );
  }
}
