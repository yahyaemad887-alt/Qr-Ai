// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QRItemAdapter extends TypeAdapter<QRItem> {
  @override
  final int typeId = 0;

  @override
  QRItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QRItem(
      id: fields[0] as String,
      data: fields[1] as String,
      type: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QRItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QRItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
