import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  // IMPORTANT: Ensure this key has "Maps SDK for Android" enabled in Google Cloud Console
  final String googleApiKey = "AIzaSyCMPKWfhk2GeJfR-4ausWy5M0C6yW4ANL0";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          ),
        );
      }

      setState(() {
        _isLoading = false;
        _markers.add(
          Marker(
            markerId: const MarkerId("current_loc"),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: "You are here"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          ),
        );
      });
      _findRestAreas();
    } catch (e) {
      debugPrint("Location Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _findRestAreas() async {
    if (_currentPosition == null) return;
    
    // Using HTTPS is mandatory for newer Android versions
    final String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=5000&type=rest_area|gas_station|cafe&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        setState(() {
          for (var res in results) {
            _markers.add(
              Marker(
                markerId: MarkerId(res['place_id']),
                position: LatLng(res['geometry']['location']['lat'], res['geometry']['location']['lng']),
                infoWindow: InfoWindow(title: res['name'], snippet: "Tap for details"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            );
          }
        });
      } else {
        // Show the actual error message from Google to the user
        String error = data['error_message'] ?? data['status'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Google API: $error"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Nearby Rest Areas", style: TextStyle(color: Colors.cyanAccent)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)) 
        : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentPosition?.latitude ?? 0, _currentPosition?.longitude ?? 0),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
    );
  }
}
