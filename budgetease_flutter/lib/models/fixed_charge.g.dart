// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_charge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FixedChargeAdapter extends TypeAdapter<FixedCharge> {
  @override
  final int typeId = 4;

  @override
  FixedCharge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixedCharge(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      frequency: fields[3] as String,
      nextDueDate: fields[4] as DateTime,
      isActive: fields[5] as bool,
      categoryId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FixedCharge obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.nextDueDate)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedChargeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
