import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../data/models/nearby_place.dart';

/// Service for handling location and nearby places functionality
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();

  /// Get stream of position updates
  Stream<Position> get positionStream => _positionController.stream;

  /// Get current position
  Position? get currentPosition => _currentPosition;

  /// Initialize location services
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get initial position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start listening to position updates
  void startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _positionController.add(position);
    });
  }

  /// Stop listening to position updates
  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      return position;
    } catch (e) {
      return null;
    }
  }

  /// Find nearby places of a specific type
  Future<List<NearbyPlace>> findNearbyPlaces({
    required String placeType,
    double radius = 5000, // 5km radius
  }) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }

    if (_currentPosition == null) {
      return [];
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=$radius'
        '&type=$placeType'
        '&key=${AppConstants.googleMapsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return results.map((place) => NearbyPlace.fromGooglePlace(place)).toList();
      }
    } catch (e) {
      // Handle error
    }

    return [];
  }

  /// Find nearby hospitals
  Future<List<NearbyPlace>> findNearbyHospitals() async {
    return await findNearbyPlaces(placeType: 'hospital');
  }

  /// Find nearby gas stations
  Future<List<NearbyPlace>> findNearbyGasStations() async {
    return await findNearbyPlaces(placeType: 'gas_station');
  }

  /// Find nearby restaurants
  Future<List<NearbyPlace>> findNearbyRestaurants() async {
    return await findNearbyPlaces(placeType: 'restaurant');
  }

  /// Find nearby hotels
  Future<List<NearbyPlace>> findNearbyHotels() async {
    return await findNearbyPlaces(placeType: 'lodging');
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=${AppConstants.googleMapsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (results.isNotEmpty) {
          return results.first['formatted_address'] ?? 'Unknown location';
        }
      }
    } catch (e) {
      // Handle error
    }

    return 'Unknown location';
  }

  /// Get coordinates from address (geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&key=${AppConstants.googleMapsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (results.isNotEmpty) {
          final location = results.first['geometry']['location'];
          return Position(
            latitude: location['lat'],
            longitude: location['lng'],
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }
    } catch (e) {
      // Handle error
    }

    return null;
  }

  /// Dispose resources
  void dispose() {
    stopLocationUpdates();
    _positionController.close();
  }
}