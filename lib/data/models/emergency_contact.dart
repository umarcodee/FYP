import 'package:hive/hive.dart';

part 'emergency_contact.g.dart';

/// Model class for emergency contacts
@HiveType(typeId: 1)
class EmergencyContact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String? relationship;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final bool isPrimary;

  @HiveField(6)
  final bool enableSmsAlerts;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? lastContactedAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    this.email,
    this.isPrimary = false,
    this.enableSmsAlerts = true,
    required this.createdAt,
    this.lastContactedAt,
  });

  /// Factory constructor to create EmergencyContact from JSON
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String?,
      email: json['email'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      enableSmsAlerts: json['enableSmsAlerts'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastContactedAt: json['lastContactedAt'] != null 
          ? DateTime.parse(json['lastContactedAt'] as String)
          : null,
    );
  }

  /// Convert EmergencyContact to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'email': email,
      'isPrimary': isPrimary,
      'enableSmsAlerts': enableSmsAlerts,
      'createdAt': createdAt.toIso8601String(),
      'lastContactedAt': lastContactedAt?.toIso8601String(),
    };
  }

  /// Get formatted phone number for display
  String get formattedPhoneNumber {
    if (phoneNumber.length >= 10) {
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (cleaned.length == 10) {
        return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
      } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
        return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
      }
    }
    return phoneNumber;
  }

  /// Get display name with relationship
  String get displayName {
    if (relationship != null && relationship!.isNotEmpty) {
      return '$name ($relationship)';
    }
    return name;
  }

  /// Validate phone number format
  bool get isValidPhoneNumber {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  /// Validate email format
  bool get isValidEmail {
    if (email == null || email!.isEmpty) return true; // Email is optional
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!);
  }

  /// Check if contact is valid for emergency use
  bool get isValid {
    return name.isNotEmpty && isValidPhoneNumber && isValidEmail;
  }

  /// Get time since last contact
  String get lastContactedDescription {
    if (lastContactedAt == null) return 'Never contacted';
    
    final difference = DateTime.now().difference(lastContactedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'EmergencyContact{'
           'name: $name, '
           'phone: $formattedPhoneNumber, '
           'relationship: $relationship, '
           'isPrimary: $isPrimary'
           '}';
  }

  /// Create a copy of this contact with updated fields
  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    String? email,
    bool? isPrimary,
    bool? enableSmsAlerts,
    DateTime? createdAt,
    DateTime? lastContactedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      isPrimary: isPrimary ?? this.isPrimary,
      enableSmsAlerts: enableSmsAlerts ?? this.enableSmsAlerts,
      createdAt: createdAt ?? this.createdAt,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
    );
  }

  /// Update last contacted timestamp
  EmergencyContact markAsContacted() {
    return copyWith(lastContactedAt: DateTime.now());
  }
}