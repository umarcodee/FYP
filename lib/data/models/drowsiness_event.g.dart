// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drowsiness_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrowsinessEventAdapter extends TypeAdapter<DrowsinessEvent> {
  @override
  final int typeId = 2;

  @override
  DrowsinessEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrowsinessEvent(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      severity: fields[2] as String,
      confidence: fields[3] as double,
      duration: fields[4] as Duration,
      location: fields[5] as Position?,
      notes: fields[6] as String?,
      actionTaken: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DrowsinessEvent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.actionTaken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrowsinessEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}