// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_place.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NearbyPlaceAdapter extends TypeAdapter<NearbyPlace> {
  @override
  final int typeId = 3;

  @override
  NearbyPlace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NearbyPlace(
      placeId: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      rating: fields[5] as double?,
      phoneNumber: fields[6] as String?,
      website: fields[7] as String?,
      types: (fields[8] as List).cast<String>(),
      isOpen: fields[9] as bool,
      openingHours: fields[10] as String?,
      distanceFromUser: fields[11] as double,
      photoReference: fields[12] as String?,
      priceLevel: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, NearbyPlace obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.placeId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.phoneNumber)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.types)
      ..writeByte(9)
      ..write(obj.isOpen)
      ..writeByte(10)
      ..write(obj.openingHours)
      ..writeByte(11)
      ..write(obj.distanceFromUser)
      ..writeByte(12)
      ..write(obj.photoReference)
      ..writeByte(13)
      ..write(obj.priceLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyPlaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}