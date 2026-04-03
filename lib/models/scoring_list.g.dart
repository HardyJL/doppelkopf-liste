// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoringListAdapter extends TypeAdapter<ScoringList> {
  @override
  final int typeId = 2;

  @override
  ScoringList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoringList(
      title: fields[0] as String,
      timestamp: fields[1] as DateTime,
      players: (fields[2] as List).cast<String>(),
      games: (fields[3] as List).cast<Game>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScoringList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.players)
      ..writeByte(3)
      ..write(obj.games);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoringListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
