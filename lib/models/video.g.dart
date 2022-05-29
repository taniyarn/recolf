// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 0;

  @override
  Video read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Video(
      id: fields[0] as String,
      datetime: fields[1] as DateTime,
      path: fields[2] as String,
      shapes: (fields[3] as List?)?.cast<Shape>(),
    );
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.datetime)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.shapes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
