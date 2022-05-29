// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shape.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VectorAdapter extends TypeAdapter<Vector> {
  @override
  final int typeId = 1;

  @override
  Vector read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vector(
      fields[0] as double,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Vector obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LineAdapter extends TypeAdapter<Line> {
  @override
  final int typeId = 2;

  @override
  Line read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Line(
      p1: fields[1] as Vector,
      p2: fields[2] as Vector,
      active: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Line obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.p1)
      ..writeByte(2)
      ..write(obj.p2)
      ..writeByte(0)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CircleAdapter extends TypeAdapter<Circle> {
  @override
  final int typeId = 3;

  @override
  Circle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Circle(
      topLeft: fields[1] as Vector,
      bottomRight: fields[2] as Vector,
      active: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Circle obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.topLeft)
      ..writeByte(2)
      ..write(obj.bottomRight)
      ..writeByte(0)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
