// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavioral_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BehavioralProfileAdapter extends TypeAdapter<BehavioralProfile> {
  @override
  final int typeId = 5;

  @override
  BehavioralProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BehavioralProfile(
      userId: fields[0] as String,
      spendingFrequency: fields[1] as double,
      hourlyPattern: (fields[2] as Map).cast<int, int>(),
      overrunCount: fields[3] as int,
      averageOverrun: fields[4] as double,
      lastUpdated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BehavioralProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.spendingFrequency)
      ..writeByte(2)
      ..write(obj.hourlyPattern)
      ..writeByte(3)
      ..write(obj.overrunCount)
      ..writeByte(4)
      ..write(obj.averageOverrun)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehavioralProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
