import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pan/core/models/med_log.dart';
import 'package:pan/core/models/medication.dart';
import 'package:pan/features/meds/meds_provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsBoxAsync = ref.watch(medsBoxProvider);
    final logsBoxAsync = ref.watch(medLogBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-In')),
      body: medsBoxAsync.when(
        data: (medsBox) => logsBoxAsync.when(
          data: (logsBox) {
            final today = DateTime.now();
            final todayLogs = logsBox.values.where((log) {
              return log.scheduledTime.year == today.year &&
                     log.scheduledTime.month == today.month &&
                     log.scheduledTime.day == today.day;
            }).toList();

            final meds = medsBox.values.toList();

            return ListView.builder(
              itemCount: meds.length,
              itemBuilder: (_, i) {
                final med = meds[i];

                final scheduledTime = DateTime(
                  today.year,
                  today.month,
                  today.day,
                  8, 0, // Default time for now
                );

                final existingLog = todayLogs.firstWhere(
                  (log) => log.medicationKey == med.key && log.scheduledTime.hour == scheduledTime.hour,
                  orElse: () => MedLog(medicationKey: med.key, scheduledTime: scheduledTime),
                );

                return Card(
                  child: ListTile(
                    title: Text('${med.name} (${med.dose})'),
                    subtitle: Text('Dosage: ${med.dosage}\nScheduled: ${DateFormat.jm().format(scheduledTime)}'),
                    trailing: existingLog.taken
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () async {
                              existingLog.taken = true;
                              existingLog.takenTime = DateTime.now();
                              await logsBox.put(
                                '${med.key}_${scheduledTime.toIso8601String()}',
                                existingLog,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${med.name} marked as taken')),
                              );
                            },
                            child: const Text('Mark Taken'),
                          ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Log Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Med Error: $e')),
      ),
    );
  }
}
