import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DriverPage extends StatefulWidget {
  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  Location _location = Location();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
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

    // Listen to location changes
    _location.onLocationChanged.listen((newLocation) {
      // Update the UI with new location
      setState(() {
        _currentPosition =
            LatLng(newLocation.latitude ?? 0.0, newLocation.longitude ?? 0.0);
        _locationData =
            'Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}';
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
      ),
      body: Column(
        children: [
          // Google Map at the top
          SizedBox(
            height: 600, // You can adjust this height to your preference
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 18.0,
              ),
              onMapCreated: _onMapCreated,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          SizedBox(height: 20), // Space between the map and the location text
          // Location information below the map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _locationData,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
