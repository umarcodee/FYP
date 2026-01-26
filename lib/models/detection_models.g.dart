// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionEventAdapter extends TypeAdapter<DetectionEvent> {
  @override
  final int typeId = 0;

  @override
  DetectionEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionEvent(
      timestamp: fields[0] as DateTime,
      eventType: fields[1] as String,
      durationMs: fields[2] as int,
      confidenceScore: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionEvent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.eventType)
      ..writeByte(2)
      ..write(obj.durationMs)
      ..writeByte(3)
      ..write(obj.confidenceScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
