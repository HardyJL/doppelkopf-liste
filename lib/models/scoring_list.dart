// scoring_list.dart
import 'package:hive/hive.dart';
import 'game.dart';

part 'scoring_list.g.dart';

@HiveType(typeId: 2)
class ScoringList extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  List<String> players;

  @HiveField(3)
  List<Game> games;

  ScoringList({
    required this.title,
    required this.timestamp,
    required this.players,
    this.games = const [],
  });
}
