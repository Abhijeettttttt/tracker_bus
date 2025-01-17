import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraPosition _cameraPosition =
      const CameraPosition(target: LatLng(12.972060, 79.156578), zoom: 10.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("google maps"),
      ),
      body: GoogleMap(initialCameraPosition: _cameraPosition),
    );
  }
}
