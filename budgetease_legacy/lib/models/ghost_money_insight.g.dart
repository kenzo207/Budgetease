// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ghost_money_insight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GhostMoneyInsightAdapter extends TypeAdapter<GhostMoneyInsight> {
  @override
  final int typeId = 7;

  @override
  GhostMoneyInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GhostMoneyInsight(
      id: fields[0] as String,
      detectedAt: fields[1] as DateTime,
      totalAmount: fields[2] as double,
      transactionCount: fields[3] as int,
      categoryNames: (fields[4] as List).cast<String>(),
      periodDays: fields[5] as int,
      percentageOfAvailable: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GhostMoneyInsight obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.detectedAt)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.transactionCount)
      ..writeByte(4)
      ..write(obj.categoryNames)
      ..writeByte(5)
      ..write(obj.periodDays)
      ..writeByte(6)
      ..write(obj.percentageOfAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GhostMoneyInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
