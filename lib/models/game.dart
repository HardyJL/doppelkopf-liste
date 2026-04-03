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
}
