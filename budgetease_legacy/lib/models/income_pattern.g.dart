// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_pattern.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomePatternAdapter extends TypeAdapter<IncomePattern> {
  @override
  final int typeId = 6;

  @override
  IncomePattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncomePattern(
      estimatedWeeklyIncome: fields[0] as double,
      minimumObserved: fields[1] as double,
      averageObserved: fields[2] as double,
      observationDays: fields[3] as int,
      lastUpdated: fields[4] as DateTime,
      isRegular: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, IncomePattern obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.estimatedWeeklyIncome)
      ..writeByte(1)
      ..write(obj.minimumObserved)
      ..writeByte(2)
      ..write(obj.averageObserved)
      ..writeByte(3)
      ..write(obj.observationDays)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.isRegular);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomePatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
