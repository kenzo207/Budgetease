// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 2;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      currency: fields[0] as String,
      notificationEnabled: fields[1] as bool,
      notificationTime: fields[2] as String,
      onboardingCompleted: fields[3] as bool,
      favoriteCategories: (fields[4] as List).cast<String>(),
      budgetPeriod: fields[5] as String,
      sosAmount: fields[6] == null ? 0.0 : fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.notificationEnabled)
      ..writeByte(2)
      ..write(obj.notificationTime)
      ..writeByte(3)
      ..write(obj.onboardingCompleted)
      ..writeByte(4)
      ..write(obj.favoriteCategories)
      ..writeByte(5)
      ..write(obj.budgetPeriod)
      ..writeByte(6)
      ..write(obj.sosAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
