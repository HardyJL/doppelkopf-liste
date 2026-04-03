// main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/game.dart';
import 'models/scoring_list.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(ScoringListAdapter());

  await Hive.openBox<ScoringList>('scoring_lists');

  runApp(const DoppelkopfApp());
}

class DoppelkopfApp extends StatelessWidget {
  const DoppelkopfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doppelkopf Scores',
	  debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
