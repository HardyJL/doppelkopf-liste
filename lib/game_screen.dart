// game_screen.dart
import 'package:doppelkopf/models/game.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/scoring_list.dart';

class GameScreen extends StatelessWidget {
  final ScoringList scoringList;

  const GameScreen({super.key, required this.scoringList});

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<Box<ScoringList>>(
          valueListenable: Hive.box<ScoringList>('scoring_lists').listenable(),
          builder: (context, box, _) {
          final currentList = box.get(scoringList.key);
          final games = currentList?.games.toList() ?? [];

          final allPlayers = scoringList.players;
          final history = calculateCumulativeScores(
            games.cast<Game>(),
            allPlayers,
          );
          // If games is empty, we only have the initial [0,0,0,0] row from calculateCumulativeScores.
          // We want to show it.
          // If games is NOT empty, we want to skip that initial row.
          final displayHistory = games.isEmpty ? history : history.skip(1).toList();

          final colorScheme = Theme.of(context).colorScheme;
          final sitOutIndices = _getSitOutIndices(games.length, allPlayers.length);
          final sitOutNames = sitOutIndices.map((idx) => allPlayers[idx]).join(', ');
          final dealerName = allPlayers[games.length % allPlayers.length];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline, size: 20, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Next Dealer: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                dealerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          if (allPlayers.length > 4)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy, size: 20, color: colorScheme.error),
                                const SizedBox(width: 8),
                                Text(
                                  'Sits out: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  sitOutNames,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.error,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: colorScheme.primary,
                      iconSize: 28,
                      onPressed: () => _showAddGameDialog(context),
                      tooltip: 'Add Game',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(16.0),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 32, // More precise width
                        ),
                        child: Table(
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              children: [
                                ...allPlayers.map(
                                  (player) => _buildTableCell(
                                    context,
                                    player,
                                    isHeader: true,
                                  ),
                                ),
                                _buildTableCell(context, 'Pts', isHeader: true),
                                _buildTableCell(context, 'Game', isHeader: true),
                              ],
                            ),
                            ...List.generate(displayHistory.length, (index) {
                              final rowData = displayHistory[index];
                              final isInitial = games.isEmpty;
                              final game = isInitial ? null : games[index] as Game;
                              final gameNumber = isInitial ? 0 : index + 1;
                              final isRoundEnd = !isInitial && gameNumber % allPlayers.length == 0;

                              void onLongPress() {
                                if (!isInitial) {
                                  _confirmDeleteGame(context, index);
                                }
                              }

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? null
                                      : colorScheme.surfaceContainerHighest.withOpacity(
                                          0.3,
                                        ),
                                ),
                                children: [
                                  ...allPlayers.map((player) {
                                    final score = rowData[player] ?? 0;
                                    return _buildTableCell(
                                      context,
                                      score.toString(),
                                      score: score,
                                      isBold: isRoundEnd || isInitial,
                                      isRoundEnd: isRoundEnd,
                                      onLongPress: onLongPress,
                                    );
                                  }),
                                  _buildTableCell(
                                    context,
                                    game == null
                                        ? '-'
                                        : (game.isSolo
                                            ? '${3 * game.plusPoints}/${game.plusPoints}'
                                            : '${game.plusPoints}'),
                                    isRoundEnd: isRoundEnd,
                                    isBold: true,
                                    onLongPress: onLongPress,
                                  ),
                                  _buildTableCell(
                                    context,
                                    '$gameNumber',
                                    isRoundEnd: isRoundEnd,
                                    onLongPress: onLongPress,
                                    isBold: isInitial,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Future<void> _confirmDeleteGame(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete game ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      scoringList.games.removeAt(index);
      scoringList.save();
    }
  }

  Future<void> _showAddGameDialog(BuildContext context) async {
    final pointsController = TextEditingController();
    List<String> selectedWinners = [];
    bool isSolo = false;
    final allPlayers = scoringList.players;
    final sitOutIndices = _getSitOutIndices(scoringList.games.length, allPlayers.length);
    final sitOutPlayers = sitOutIndices.map((idx) => allPlayers[idx]).toSet();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(16.0),
              title: const Text('Record Game'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: pointsController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Plus Points',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.add_circle_outline),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Solo Game'),
                      value: isSolo,
                      onChanged: (val) => setState(() => isSolo = val),
                    ),
                    const Divider(),
                    Text(
                      'Select Winners',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ...allPlayers.map((player) {
                      final isSittingOut = sitOutPlayers.contains(player);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          player + (isSittingOut ? ' (Sitting out)' : ''),
                          style: TextStyle(
                            color: isSittingOut ? Colors.grey : null,
                            fontStyle: isSittingOut ? FontStyle.italic : null,
                          ),
                        ),
                        value: selectedWinners.contains(player),
                        onChanged: isSittingOut
                            ? null
                            : (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedWinners.add(player);
                                  } else {
                                    selectedWinners.remove(player);
                                  }
                                  isSolo = selectedWinners.length == 1;
                                });
                              },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final points = int.tryParse(pointsController.text);
                    if (points != null && selectedWinners.isNotEmpty) {
                      scoringList.games.add(
                        Game(
                          winners: selectedWinners,
                          plusPoints: points,
                          isSolo: isSolo,
                        ),
                      );
                      scoringList.save();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, int>> calculateCumulativeScores(
    List<Game> games,
    List<String> allPlayers,
  ) {
    List<Map<String, int>> history = [];
    Map<String, int> runningTotals = {for (var player in allPlayers) player: 0};

    // Add initial state (Game 0)
    history.add(Map.from(runningTotals));

    for (int i = 0; i < games.length; i++) {
      final game = games[i];
      final sitOutIndices = _getSitOutIndices(i, allPlayers.length);
      final sitOutPlayers = sitOutIndices.map((idx) => allPlayers[idx]).toSet();

      int winnerCount = game.winners.length;
      // Losers are the players who are not winners and not sitting out
      int playingCount = allPlayers.length - sitOutPlayers.length;
      int loserCount = playingCount - winnerCount;

      int winnerDelta = game.isSolo
          ? (game.plusPoints * loserCount)
          : game.plusPoints;
      int loserDelta = -game.plusPoints;

      for (var player in allPlayers) {
        if (sitOutPlayers.contains(player)) {
          // Score remains unchanged
          continue;
        }
        if (game.winners.contains(player)) {
          runningTotals[player] = runningTotals[player]! + winnerDelta;
        } else {
          runningTotals[player] = runningTotals[player]! + loserDelta;
        }
      }

      history.add(Map.from(runningTotals));
    }

    return history;
  }

  List<int> _getSitOutIndices(int gameIndex, int playerCount) {
    if (playerCount <= 4) return [];
    int numSitOut = playerCount - 4;
    int dealerIndex = gameIndex % playerCount;
    return List.generate(numSitOut, (k) => (dealerIndex + 2 * k) % playerCount);
  }

  Widget _buildTableCell(
    BuildContext context,
    String text, {
    bool isHeader = false,
    int? score,
    bool isBold = false,
    bool isRoundEnd = false,
    VoidCallback? onLongPress,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isRoundEnd ? colorScheme.outline : colorScheme.outlineVariant,
              width: isRoundEnd ? 3.0 : 1.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Text(
          text,
          textAlign: score != null ? TextAlign.right : TextAlign.center,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.w500,
            color: score == null
                ? null
                : (score < 0 ? Colors.red.shade700 : Colors.green.shade700),
          ),
        ),
      ),
    );
  }
}
