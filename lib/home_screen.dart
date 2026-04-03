// home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/scoring_list.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doppelkopf Scores')),
      body: ValueListenableBuilder<Box<ScoringList>>(
        valueListenable: Hive.box<ScoringList>('scoring_lists').listenable(),
        builder: (context, box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No lists found.'));
          }

          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final scoringList = box.getAt(index);
              if (scoringList == null) return const SizedBox.shrink();

              return ListTile(
                title: Text('Game: ${scoringList.title}'),
                subtitle: Text(
                  scoringList.timestamp.toLocal().toString().split('.')[0],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(scoringList: scoringList),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewGameDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewGameDialog(BuildContext context) {
    final newPlayerController = TextEditingController();
    final titleController = TextEditingController();
    final selectedPlayers = <String>[];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Game Session'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: selectedPlayers.map((player) {
                        return Chip(
                          label: Text(player),
                          onDeleted: () {
                            setState(() => selectedPlayers.remove(player));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newPlayerController,
                            decoration: const InputDecoration(
                              labelText: 'Create New Player',
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final name = newPlayerController.text.trim();
                            if (name.isNotEmpty) {
                              setState(() {
                                selectedPlayers.add(name);
                                newPlayerController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selectedPlayers.isNotEmpty
                      ? () {
                          final title = titleController.text.trim();
                          final newScoringList = ScoringList(
                            title: title.isNotEmpty
                                ? title
                                : DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                            timestamp: DateTime.now(),
                            players: selectedPlayers,
                            games: [],
                          );
                          Hive.box<ScoringList>(
                            'scoring_lists',
                          ).add(newScoringList);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Start'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
