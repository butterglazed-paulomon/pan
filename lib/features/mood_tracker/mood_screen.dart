import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/mood_entry.dart';

final moodBoxProvider = FutureProvider<Box<MoodEntry>>((ref) async {
  return Hive.openBox<MoodEntry>('moods');
});

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int _mood = 5;
  final _noteController = TextEditingController();

  void _saveMood(Box<MoodEntry> box) {
    final entry = MoodEntry(
      date: DateTime.now(),
      mood: _mood,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text,
    );
    box.add(entry);
    _noteController.clear();
    setState(() {
      _mood = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodBoxAsync = ref.watch(moodBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker 😊')),
      body: moodBoxAsync.when(
        data: (box) {
          final moods = box.values.toList().reversed.toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('How do you feel today?', style: Theme.of(context).textTheme.titleLarge),
                Slider(
                  value: _mood.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _mood.toString(),
                  onChanged: (value) => setState(() => _mood = value.toInt()),
                ),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Optional note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _saveMood(box),
                  icon: const Icon(Icons.check),
                  label: const Text('Save Entry'),
                ),
                const Divider(height: 32),
                const Text('Recent Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: moods.length,
                    itemBuilder: (context, index) {
                      final entry = moods[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(entry.mood.toString())),
                        title: Text(entry.note ?? 'No note'),
                        subtitle: Text(entry.date.toLocal().toString().split('.')[0]),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
