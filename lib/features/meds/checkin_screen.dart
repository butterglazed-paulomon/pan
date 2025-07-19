import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/med_log.dart';
import '../../core/providers/log_box.dart';

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-in')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<MedLog>('med_logs').listenable(),
        builder: (context, Box<MedLog> box, _) {
          final logs = box.values.toList();

          final Map<String, List<MedLog>> grouped = {};
          for (final log in logs) {
            grouped.putIfAbsent(log.medicationName, () => []).add(log);
          }

          if (grouped.isEmpty) {
            return const Center(child: Text('No logs found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              final medName = entry.key;
              final medLogs = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...medLogs.map((log) => ListTile(
                            title: Text(log.dose),
                            subtitle: Text(log.timestamp.toLocal().toString()),
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
