// game.dart
import 'package:hive/hive.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  List<String> winners;

  @HiveField(1)
  int plusPoints;

  @HiveField(2)
  bool isSolo;

  Game({required this.winners, required this.plusPoints, this.isSolo = false});

  Map<String, dynamic> toJson() => {
        'winners': winners,
        'plusPoints': plusPoints,
        'isSolo': isSolo,
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        winners: (json['winners'] as List).cast<String>(),
        plusPoints: json['plusPoints'] as int,
        isSolo: json['isSolo'] as bool? ?? false,
      );
}
