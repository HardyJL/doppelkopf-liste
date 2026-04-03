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
  await Hive.openBox('settings');

  runApp(const DoppelkopfApp());
}

class DoppelkopfApp extends StatelessWidget {
  const DoppelkopfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(keys: ['themeMode']),
      builder: (context, box, _) {
        final themeValue = box.get('themeMode', defaultValue: 'system');
        ThemeMode themeMode = ThemeMode.system;
        if (themeValue == 'light') themeMode = ThemeMode.light;
        if (themeValue == 'dark') themeMode = ThemeMode.dark;
        final seedColor = Color.fromRGBO(205, 133, 63, 1);
        final backgroundColor = Color.fromRGBO(18, 18, 18, 1);

        return MaterialApp(
          title: 'Doppelkopf Lists',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
              surface: backgroundColor,
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
