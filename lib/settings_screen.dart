import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models/scoring_list.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box(
              'settings',
            ).listenable(keys: ['themeMode']),
            builder: (context, box, _) {
              final themeMode = box.get('themeMode', defaultValue: 'system');
              return Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('System Default'),
                    value: 'system',
                    groupValue: themeMode,
                    onChanged: (val) => box.put('themeMode', val),
                  ),
                  RadioListTile<String>(
                    title: const Text('Light Mode'),
                    value: 'light',
                    groupValue: themeMode,
                    onChanged: (val) => box.put('themeMode', val),
                  ),
                  RadioListTile<String>(
                    title: const Text('Dark Mode'),
                    value: 'dark',
                    groupValue: themeMode,
                    onChanged: (val) => box.put('themeMode', val),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Sorting',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box(
              'settings',
            ).listenable(keys: ['sortOption']),
            builder: (context, box, _) {
              final sortOption = box.get(
                'sortOption',
                defaultValue: 'date_desc',
              );
              return Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Date (Newest first)'),
                    value: 'date_desc',
                    groupValue: sortOption,
                    onChanged: (val) => box.put('sortOption', val),
                  ),
                  RadioListTile<String>(
                    title: const Text('Date (Oldest first)'),
                    value: 'date_asc',
                    groupValue: sortOption,
                    onChanged: (val) => box.put('sortOption', val),
                  ),
                  RadioListTile<String>(
                    title: const Text('Title (A-Z)'),
                    value: 'title_asc',
                    groupValue: sortOption,
                    onChanged: (val) => box.put('sortOption', val),
                  ),
                  RadioListTile<String>(
                    title: const Text('Title (Z-A)'),
                    value: 'title_desc',
                    groupValue: sortOption,
                    onChanged: (val) => box.put('sortOption', val),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data Management',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Data'),
            subtitle: const Text('Save your lists to a file to import later'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            subtitle: const Text('Load lists from a previously exported file'),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final box = Hive.box<ScoringList>('scoring_lists');
      final data = box.values.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(data);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/doppelkopf_export.json');
      await file.writeAsString(jsonString);

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Doppelkopf Export');

      if (context.mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export successful!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);

      final box = Hive.box<ScoringList>('scoring_lists');
      int importedCount = 0;

      for (final item in jsonData) {
        final scoringList = ScoringList.fromJson(item as Map<String, dynamic>);
        await box.add(scoringList);
        importedCount++;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $importedCount lists!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}
