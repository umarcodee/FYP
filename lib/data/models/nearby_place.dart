import 'package:hive/hive.dart';
import 'dart:math' show atan2, cos, pi, sin, sqrt;

part 'nearby_place.g.dart';

/// Model class for nearby places (rest stops, petrol pumps, hospitals)
@HiveType(typeId: 3)
class NearbyPlace extends HiveObject {
  @HiveField(0)
  final String placeId;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String address;
  
  @HiveField(3)
  final double latitude;
  
  @HiveField(4)
  final double longitude;
  
  @HiveField(5)
  final double? rating;
  
  @HiveField(6)
  final String? phoneNumber;
  
  @HiveField(7)
  final String? website;
  
  @HiveField(8)
  final List<String> types;
  
  @HiveField(9)
  final bool isOpen;
  
  @HiveField(10)
  final String? openingHours;
  
  @HiveField(11)
  final double distanceFromUser; // in meters
  
  @HiveField(12)
  final String? photoReference;
  
  @HiveField(13)
  final int? priceLevel;

  NearbyPlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.phoneNumber,
    this.website,
    required this.types,
    this.isOpen = true,
    this.openingHours,
    required this.distanceFromUser,
    this.photoReference,
    this.priceLevel,
  });

  /// Factory constructor to create NearbyPlace from Google Places API response
  factory NearbyPlace.fromGooglePlace(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    final lat = geometry['lat'] as double;
    final lng = geometry['lng'] as double;
    
    return NearbyPlace(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['vicinity'] as String? ?? json['formatted_address'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      rating: json['rating']?.toDouble(),
      phoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      types: List<String>.from(json['types'] ?? []),
      isOpen: json['opening_hours']?['open_now'] ?? true,
      openingHours: json['opening_hours']?['weekday_text']?.join('\n'),
      distanceFromUser: 0.0, // Will be calculated separately
      photoReference: json['photos']?[0]?['photo_reference'],
      priceLevel: json['price_level'] as int?,
    );
  }

  /// Factory constructor to create NearbyPlace from Google Places API response with user location
  factory NearbyPlace.fromGooglePlaces(Map<String, dynamic> json, double userLat, double userLng) {
    final geometry = json['geometry']['location'];
    final lat = geometry['lat'] as double;
    final lng = geometry['lng'] as double;
    
    // Calculate distance from user location
    final distance = _calculateDistance(userLat, userLng, lat, lng);
    
    return NearbyPlace(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['vicinity'] as String? ?? json['formatted_address'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      rating: json['rating']?.toDouble(),
      phoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      types: List<String>.from(json['types'] ?? []),
      isOpen: json['opening_hours']?['open_now'] ?? true,
      openingHours: json['opening_hours']?['weekday_text']?.join('\n'),
      distanceFromUser: distance,
      photoReference: json['photos']?[0]?['photo_reference'],
      priceLevel: json['price_level'] as int?,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // Earth radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = 
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        (sin(dLng / 2) * sin(dLng / 2));
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Convert NearbyPlace to JSON
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'phoneNumber': phoneNumber,
      'website': website,
      'types': types,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'distanceFromUser': distanceFromUser,
      'photoReference': photoReference,
      'priceLevel': priceLevel,
    };
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceFromUser < 1000) {
      return '${distanceFromUser.round()}m';
    } else {
      return '${(distanceFromUser / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Get formatted rating string
  String get formattedRating {
    if (rating == null) return 'No rating';
    return '${rating!.toStringAsFixed(1)} ⭐';
  }

  /// Get place type icon
  String get typeIcon {
    if (types.contains('gas_station')) return '⛽';
    if (types.contains('hospital')) return '🏥';
    if (types.contains('rest_area')) return '🛌';
    if (types.contains('restaurant')) return '🍽️';
    if (types.contains('lodging')) return '🏨';
    return '📍';
  }

  /// Get place category
  String get category {
    if (types.contains('gas_station')) return 'Petrol Pump';
    if (types.contains('hospital')) return 'Hospital';
    if (types.contains('rest_area')) return 'Rest Stop';
    if (types.contains('restaurant')) return 'Restaurant';
    if (types.contains('lodging')) return 'Hotel';
    return 'Place';
  }

  /// Get opening status description
  String get openingStatus {
    if (isOpen) return 'Open';
    return 'Closed';
  }

  /// Get price level description
  String get priceLevelDescription {
    switch (priceLevel) {
      case 0:
        return 'Free';
      case 1:
        return 'Inexpensive';
      case 2:
        return 'Moderate';
      case 3:
        return 'Expensive';
      case 4:
        return 'Very Expensive';
      default:
        return 'Price not available';
    }
  }

  /// Get Google Maps URL for directions
  String get directionsUrl {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }

  /// Get Google Maps URL for place details
  String get placeUrl {
    return 'https://www.google.com/maps/place/?q=place_id:$placeId';
  }

  @override
  String toString() {
    return 'NearbyPlace{'
           'name: $name, '
           'category: $category, '
           'distance: $formattedDistance, '
           'rating: $formattedRating, '
           'isOpen: $isOpen'
           '}';
  }

  /// Compare places by distance
  int compareTo(NearbyPlace other) {
    return distanceFromUser.compareTo(other.distanceFromUser);
  }
}