// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'med_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedLogAdapter extends TypeAdapter<MedLog> {
  @override
  final int typeId = 2;

  @override
  MedLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedLog(
      medicationKey: fields[0] as int,
      scheduledTime: fields[1] as DateTime,
      takenTime: fields[2] as DateTime?,
      notes: fields[4] as String?,
      taken: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.medicationKey)
      ..writeByte(1)
      ..write(obj.scheduledTime)
      ..writeByte(2)
      ..write(obj.takenTime)
      ..writeByte(3)
      ..write(obj.taken)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
