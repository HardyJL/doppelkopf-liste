// home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/scoring_list.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doppelkopf Lists'),
        actions: [
          ValueListenableBuilder(
            valueListenable: settingsBox.listenable(keys: ['sortOption']),
            builder: (context, box, _) {
              final currentSort = box.get('sortOption', defaultValue: 'date_desc');
              return PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort lists',
                onSelected: (String value) {
                  box.put('sortOption', value);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  CheckedPopupMenuItem<String>(
                    value: 'date_desc',
                    checked: currentSort == 'date_desc',
                    child: const Text('Date (Newest first)'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'date_asc',
                    checked: currentSort == 'date_asc',
                    child: const Text('Date (Oldest first)'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'title_asc',
                    checked: currentSort == 'title_asc',
                    child: const Text('Title (A-Z)'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'title_desc',
                    checked: currentSort == 'title_desc',
                    child: const Text('Title (Z-A)'),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: settingsBox.listenable(keys: ['sortOption']),
        builder: (context, sBox, _) {
          final sortOption = sBox.get('sortOption', defaultValue: 'date_desc');

          return ValueListenableBuilder<Box<ScoringList>>(
            valueListenable: Hive.box<ScoringList>(
              'scoring_lists',
            ).listenable(),
            builder: (context, box, _) {
              if (box.values.isEmpty) {
                return const Center(child: Text('No lists found.'));
              }

              final sortedLists = box.values.toList();

              switch (sortOption) {
                case 'date_asc':
                  sortedLists.sort(
                    (a, b) => a.timestamp.compareTo(b.timestamp),
                  );
                  break;
                case 'date_desc':
                  sortedLists.sort(
                    (a, b) => b.timestamp.compareTo(a.timestamp),
                  );
                  break;
                case 'title_asc':
                  sortedLists.sort(
                    (a, b) =>
                        a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                  );
                  break;
                case 'title_desc':
                  sortedLists.sort(
                    (a, b) =>
                        b.title.toLowerCase().compareTo(a.title.toLowerCase()),
                  );
                  break;
              }

              return ListView.builder(
                itemCount: sortedLists.length,
                itemBuilder: (context, index) {
                  final scoringList = sortedLists[index];

                  return ListTile(
                    title: Text(scoringList.title),
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
