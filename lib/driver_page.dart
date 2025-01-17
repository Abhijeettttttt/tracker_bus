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

  @override
  void initState() {
    super.initState();
    _getDriverLocation();
  }

  Future<void> _getDriverLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    // Check location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the driver's current location
    LocationData locationData = await _location.getLocation();

    setState(() {
      _currentPosition =
          LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
      _markers.add(
        Marker(
          markerId: MarkerId('driverLocation'),
          position: _currentPosition,
          infoWindow: InfoWindow(title: 'Driver\'s Location'),
        ),
      );
    });

    // Listen to location changes
    _location.onLocationChanged.listen((newLocation) {
      setState(() {
        _currentPosition =
            LatLng(newLocation.latitude ?? 0.0, newLocation.longitude ?? 0.0);
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('driverLocation'),
            position: _currentPosition,
            infoWindow: InfoWindow(title: 'Driver\'s Location'),
          ),
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
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
