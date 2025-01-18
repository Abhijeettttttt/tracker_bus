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
  LatLng _currentPosition = LatLng(12.972060, 79.156578); // Default location

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenForDriverChanges();
    _addHardcodedMarker(); // Add hardcoded marker
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
      _currentPosition =
          LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position: _currentPosition,
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });

    _location.onLocationChanged.listen((newLocation) {
      if (!mounted) return;
      setState(() {
        _currentPosition =
            LatLng(newLocation.latitude ?? 0.0, newLocation.longitude ?? 0.0);
        _markers.removeWhere((marker) => marker.markerId.value == 'userLocation');
        _markers.add(
          Marker(
            markerId: MarkerId('userLocation'),
            position: _currentPosition,
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 18.0),
        );
      });
    });
  }

  // Listen for changes in drivers' shift statuses and locations
  void _listenForDriverChanges() {
    FirebaseFirestore.instance
        .collection('drivers')
        .snapshots()
        .listen((snapshot) {
      Set<Marker> updatedMarkers = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();
        bool isShiftActive = data['isShiftActive'] ?? false;

        if (isShiftActive) {
          LatLng driverLocation = LatLng(
            data['location'].latitude,
            data['location'].longitude,
          );
          String route = data['selectedRoute'];
          Color markerColor = route == "Men's Hostel" ? Colors.blue : Colors.orange;

          updatedMarkers.add(Marker(
            markerId: MarkerId(doc.id),
            position: driverLocation,
            infoWindow: InfoWindow(title: 'Driver: ${doc.id}, Route: $route'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              markerColor == Colors.blue
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueOrange,
            ),
          ));
        }
      }

      if (mounted) {
        setState(() {
          _markers = {
            ..._markers.where((marker) => marker.markerId.value == 'userLocation'),
            ...updatedMarkers
          };
        });
      }
    });
  }

  // Add a hardcoded marker
  void _addHardcodedMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('hardcodedMarker'),
          position: LatLng(12.971598, 79.159100), // Example coordinates
          infoWindow: InfoWindow(title: 'Hardcoded Marker'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
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
            ListTile(
              title: Text('Other Option 1'),
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
          target: _currentPosition,
          zoom: 18.0,
        ),
        onMapCreated: _onMapCreated,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
