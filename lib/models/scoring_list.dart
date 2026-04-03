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

  @HiveField(4, defaultValue: 0)
  int pendingBockGames;

  ScoringList({
    required this.title,
    required this.timestamp,
    required this.players,
    this.games = const [],
    this.pendingBockGames = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'timestamp': timestamp.toIso8601String(),
        'players': players,
        'games': games.map((e) => e.toJson()).toList(),
        'pendingBockGames': pendingBockGames,
      };

  factory ScoringList.fromJson(Map<String, dynamic> json) => ScoringList(
        title: json['title'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        players: (json['players'] as List).cast<String>(),
        games: (json['games'] as List)
            .map((e) => Game.fromJson(e as Map<String, dynamic>))
            .toList(),
        pendingBockGames: json['pendingBockGames'] as int? ?? 0,
      );
}
