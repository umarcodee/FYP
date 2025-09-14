import 'package:hive/hive.dart';
import '../models/emergency_contact.dart';

/// Repository for managing emergency contacts in local storage
class EmergencyContactRepository {
  static const String _boxName = 'emergency_contacts';
  late Box<EmergencyContact> _box;

  /// Initialize the repository
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<EmergencyContact>(_boxName);
    } else {
      _box = Hive.box<EmergencyContact>(_boxName);
    }
  }

  /// Add a new emergency contact
  Future<void> addContact(EmergencyContact contact) async {
    await _box.put(contact.id, contact);
  }

  /// Update an existing emergency contact
  Future<void> updateContact(EmergencyContact contact) async {
    await _box.put(contact.id, contact);
  }

  /// Delete an emergency contact
  Future<void> deleteContact(String contactId) async {
    await _box.delete(contactId);
  }

  /// Get a specific emergency contact by ID
  EmergencyContact? getContact(String contactId) {
    return _box.get(contactId);
  }

  /// Get all emergency contacts
  List<EmergencyContact> getAllContacts() {
    return _box.values.toList();
  }

  /// Get primary emergency contact
  EmergencyContact? getPrimaryContact() {
    return _box.values.where((contact) => contact.isPrimary).firstOrNull;
  }

  /// Get contacts with SMS alerts enabled
  List<EmergencyContact> getContactsWithSmsEnabled() {
    return _box.values.where((contact) => contact.enableSmsAlerts).toList();
  }

  /// Set a contact as primary (and remove primary from others)
  Future<void> setPrimaryContact(String contactId) async {
    final contacts = getAllContacts();
    
    for (final contact in contacts) {
      if (contact.id == contactId) {
        // Set as primary
        final updatedContact = contact.copyWith(isPrimary: true);
        await updateContact(updatedContact);
      } else if (contact.isPrimary) {
        // Remove primary from others
        final updatedContact = contact.copyWith(isPrimary: false);
        await updateContact(updatedContact);
      }
    }
  }

  /// Search contacts by name or phone number
  List<EmergencyContact> searchContacts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
             contact.phoneNumber.contains(query) ||
             (contact.relationship?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Get contacts count
  int getContactsCount() {
    return _box.length;
  }

  /// Check if a phone number already exists
  bool phoneNumberExists(String phoneNumber, {String? excludeContactId}) {
    return _box.values.any((contact) {
      if (excludeContactId != null && contact.id == excludeContactId) {
        return false; // Exclude the contact being updated
      }
      return contact.phoneNumber == phoneNumber;
    });
  }

  /// Mark contact as contacted
  Future<void> markContactAsContacted(String contactId) async {
    final contact = getContact(contactId);
    if (contact != null) {
      final updatedContact = contact.markAsContacted();
      await updateContact(updatedContact);
    }
  }

  /// Get recently contacted contacts
  List<EmergencyContact> getRecentlyContactedContacts({int limit = 5}) {
    final contacts = getAllContacts();
    contacts.sort((a, b) {
      if (a.lastContactedAt == null && b.lastContactedAt == null) return 0;
      if (a.lastContactedAt == null) return 1;
      if (b.lastContactedAt == null) return -1;
      return b.lastContactedAt!.compareTo(a.lastContactedAt!);
    });
    
    return contacts.take(limit).toList();
  }

  /// Export contacts (for backup)
  List<Map<String, dynamic>> exportContacts() {
    return getAllContacts().map((contact) {
      return {
        'id': contact.id,
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'relationship': contact.relationship,
        'email': contact.email,
        'isPrimary': contact.isPrimary,
        'enableSmsAlerts': contact.enableSmsAlerts,
        'createdAt': contact.createdAt.toIso8601String(),
        'lastContactedAt': contact.lastContactedAt?.toIso8601String(),
      };
    }).toList();
  }

  /// Import contacts (from backup)
  Future<void> importContacts(List<Map<String, dynamic>> contactsData) async {
    for (final contactData in contactsData) {
      final contact = EmergencyContact(
        id: contactData['id'],
        name: contactData['name'],
        phoneNumber: contactData['phoneNumber'],
        relationship: contactData['relationship'],
        email: contactData['email'],
        isPrimary: contactData['isPrimary'] ?? false,
        enableSmsAlerts: contactData['enableSmsAlerts'] ?? true,
        createdAt: DateTime.parse(contactData['createdAt']),
        lastContactedAt: contactData['lastContactedAt'] != null
            ? DateTime.parse(contactData['lastContactedAt'])
            : null,
      );
      
      await addContact(contact);
    }
  }

  /// Clear all contacts
  Future<void> clearAllContacts() async {
    await _box.clear();
  }

  /// Close the repository
  Future<void> close() async {
    if (_box.isOpen) {
      await _box.close();
    }
  }
}