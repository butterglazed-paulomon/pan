import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/medication.dart';
import '../../core/models/med_log.dart';
import '../../core/models/reminder_time.dart';

final medsBoxProvider = FutureProvider<Box<Medication>>((ref) async {
  return Hive.openBox<Medication>('medications');
});

final medLogBoxProvider = FutureProvider<Box<MedLog>>((ref) async {
  return Hive.openBox<MedLog>('med_logs');
});

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsBoxAsync = ref.watch(medsBoxProvider);
    final logBoxAsync = ref.watch(medLogBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Check In Medications')),
      body: medsBoxAsync.when(
        data: (medsBox) {
          final meds = medsBox.toMap();

          return logBoxAsync.when(
            data: (logBox) {
              final now = DateTime.now();
              final todayLogs = logBox.values.where((log) {
                return log.takenTime?.year == now.year &&
                    log.takenTime?.month == now.month &&
                    log.takenTime?.day == now.day;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: meds.entries.map((entry) {
                  final medKey = entry.key;
                  final med = entry.value;

                  final alreadyTaken = todayLogs.any((log) =>
                      log.medicationKey == med.name);

                  return Card(
                    child: ListTile(
                      title: Text('${med.name} (${med.dose})'),
                      subtitle: Text(
                        'Dosage: ${med.dosage}\n'
                        'Frequency: ${med.frequency}'
                        '${med.notes != null ? '\nNote: ${med.notes}' : ''}',
                      ),
                      trailing: alreadyTaken
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () async {
                                final log = MedLog(
                                  medicationKey: medKey,
                                  takenTime: DateTime.now(),
                                  scheduledTime: DateTime.now(),
                                );
                                await logBox.add(log);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${med.name} marked as taken')),
                                );
                              },
                              child: const Text('Mark as Taken'),
                            ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading logs: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
