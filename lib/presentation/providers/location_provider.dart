import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../data/models/nearby_place.dart';

/// Provider for managing location services and nearby places search
class LocationProvider extends ChangeNotifier {
  // Location state
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationEnabled = false;
  bool _hasLocationPermission = false;
  bool _isLoadingLocation = false;
  String? _locationError;
  
  // Nearby places
  List<NearbyPlace> _nearbyPlaces = [];
  bool _isLoadingPlaces = false;
  String? _placesError;
  PlaceSearchType _currentSearchType = PlaceSearchType.restStops;
  
  // Stream for location updates
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  List<NearbyPlace> get nearbyPlaces => _nearbyPlaces;
  bool get isLoadingPlaces => _isLoadingPlaces;
  String? get placesError => _placesError;
  PlaceSearchType get currentSearchType => _currentSearchType;

  /// Initialize location services
  Future<void> initialize() async {
    await _checkLocationServices();
    await _requestLocationPermission();
    if (_hasLocationPermission && _isLocationEnabled) {
      await getCurrentLocation();
    }
  }

  /// Check if location services are enabled
  Future<void> _checkLocationServices() async {
    try {
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      notifyListeners();
    } catch (e) {
      print('Error checking location services: $e');
      _isLocationEnabled = false;
    }
  }

  /// Request location permission
  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permission denied permanently. Please enable in settings.';
        _hasLocationPermission = false;
      } else if (permission == LocationPermission.denied) {
        _locationError = 'Location permission denied.';
        _hasLocationPermission = false;
      } else {
        _hasLocationPermission = true;
        _locationError = null;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error requesting location permission: $e');
      _locationError = 'Error requesting location permission: $e';
      _hasLocationPermission = false;
      notifyListeners();
    }
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    if (!_hasLocationPermission || !_isLocationEnabled) {
      await initialize();
      return;
    }
    
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();
    
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );
      
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      if (_currentPosition != null) {
        await _updateAddressFromPosition(_currentPosition!);
      }
      
      _locationError = null;
    } catch (e) {
      print('Error getting location: $e');
      _locationError = 'Error getting location: ${e.toString()}';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Update address from position coordinates
  Future<void> _updateAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = _formatAddress(placemark);
      }
    } catch (e) {
      print('Error getting address: $e');
      _currentAddress = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    }
    if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      parts.add(placemark.thoroughfare!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    
    return parts.take(3).join(', '); // Limit to 3 parts for brevity
  }

  /// Start listening to location updates
  void startLocationUpdates() {
    if (!_hasLocationPermission || !_isLocationEnabled) return;
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.locationAccuracyThreshold.toInt(),
    );
    
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        _updateAddressFromPosition(position);
        notifyListeners();
      },
      onError: (e) {
        print('Location stream error: $e');
        _locationError = 'Location tracking error: $e';
        notifyListeners();
      },
    );
  }

  /// Stop listening to location updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Search for nearby places
  Future<void> searchNearbyPlaces(PlaceSearchType searchType) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
      if (_currentPosition == null) {
        _placesError = 'Location not available';
        notifyListeners();
        return;
      }
    }
    
    _currentSearchType = searchType;
    _isLoadingPlaces = true;
    _placesError = null;
    _nearbyPlaces.clear();
    notifyListeners();
    
    try {
      final places = await _fetchNearbyPlaces(searchType);
      _nearbyPlaces = places;
      _placesError = null;
    } catch (e) {
      print('Error searching nearby places: $e');
      _placesError = 'Error searching places: ${e.toString()}';
    } finally {
      _isLoadingPlaces = false;
      notifyListeners();
    }
  }

  /// Fetch nearby places from Google Places API
  Future<List<NearbyPlace>> _fetchNearbyPlaces(PlaceSearchType searchType) async {
    if (_currentPosition == null) {
      throw Exception('Current position not available');
    }
    
    final placeType = _getGooglePlaceType(searchType);
    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    final radius = AppConstants.nearbySearchRadius;
    
    // Note: In a real app, you would use the Google Places API
    // For this demo, we'll return mock data
    return _getMockNearbyPlaces(searchType, lat, lng);
  }

  /// Get Google Places API place type for search
  String _getGooglePlaceType(PlaceSearchType searchType) {
    switch (searchType) {
      case PlaceSearchType.restStops:
        return 'rest_area';
      case PlaceSearchType.petrolPumps:
        return 'gas_station';
      case PlaceSearchType.hospitals:
        return 'hospital';
      case PlaceSearchType.restaurants:
        return 'restaurant';
      case PlaceSearchType.hotels:
        return 'lodging';
    }
  }

  /// Generate mock nearby places for demo
  List<NearbyPlace> _getMockNearbyPlaces(PlaceSearchType searchType, double lat, double lng) {
    final mockPlaces = <NearbyPlace>[];
    final random = DateTime.now().millisecond;
    
    // Generate 5-10 mock places
    final count = 5 + (random % 5);
    
    for (int i = 0; i < count; i++) {
      // Generate nearby coordinates (within 5km radius)
      final offsetLat = lat + (random % 100 - 50) * 0.0001;
      final offsetLng = lng + (random % 100 - 50) * 0.0001;
      
      mockPlaces.add(NearbyPlace(
        placeId: 'mock_${searchType.name}_$i',
        name: _getMockPlaceName(searchType, i),
        address: _getMockAddress(i),
        latitude: offsetLat,
        longitude: offsetLng,
        rating: 3.5 + (random % 15) * 0.1,
        types: [_getGooglePlaceType(searchType)],
        isOpen: i % 4 != 0, // 75% open
        distanceFromUser: (500 + (random % 4500)).toDouble(),
        phoneNumber: _getMockPhoneNumber(),
      ));
    }
    
    // Sort by distance
    mockPlaces.sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));
    
    return mockPlaces;
  }

  /// Generate mock place names
  String _getMockPlaceName(PlaceSearchType searchType, int index) {
    switch (searchType) {
      case PlaceSearchType.restStops:
        final names = ['Highway Rest Area', 'Traveler\'s Stop', 'Rest Zone', 'Highway Oasis', 'Travel Center'];
        return '${names[index % names.length]} ${index + 1}';
      case PlaceSearchType.petrolPumps:
        final names = ['Shell', 'BP', 'Chevron', 'Exxon', '76', 'Arco'];
        return '${names[index % names.length]} Gas Station';
      case PlaceSearchType.hospitals:
        final names = ['General Hospital', 'Medical Center', 'Health Clinic', 'Emergency Care', 'Regional Medical'];
        return '${names[index % names.length]}';
      case PlaceSearchType.restaurants:
        final names = ['Highway Diner', 'Quick Bite', 'Road House', 'Travel Cafe', 'Express Grill'];
        return '${names[index % names.length]}';
      case PlaceSearchType.hotels:
        final names = ['Comfort Inn', 'Highway Lodge', 'Travel Motel', 'Rest Inn', 'Road Stay'];
        return '${names[index % names.length]}';
    }
  }

  /// Generate mock addresses
  String _getMockAddress(int index) {
    final streets = ['Highway 101', 'Interstate 5', 'Route 66', 'Main Street', 'Oak Avenue'];
    final numbers = [100, 250, 500, 750, 1000];
    return '${numbers[index % numbers.length]} ${streets[index % streets.length]}';
  }

  /// Generate mock phone numbers
  String _getMockPhoneNumber() {
    return '(555) 123-${4000 + DateTime.now().millisecond % 999}';
  }

  /// Get formatted location string
  String get formattedLocation {
    if (_currentAddress != null) return _currentAddress!;
    if (_currentPosition != null) {
      return '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}';
    }
    return 'Location unavailable';
  }

  /// Check if location is available
  bool get isLocationAvailable {
    return _currentPosition != null && _hasLocationPermission && _isLocationEnabled;
  }

  /// Get distance to a specific location
  double getDistanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return 0.0;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Open place in maps app
  Future<void> openInMaps(NearbyPlace place) async {
    // This would typically use url_launcher to open the maps app
    print('Opening ${place.name} in maps: ${place.directionsUrl}');
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }
}