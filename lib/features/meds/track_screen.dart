import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/models/medication.dart';
import 'package:pan/features/meds/meds_provider.dart';


class TrackScreen extends ConsumerWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsBoxAsync = ref.watch(medsBoxProvider);

    return medsBoxAsync.when(
      data: (box) {
        final today = DateTime.now();
        final meds = box.values.toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Track Medication 📆')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meds.length,
            itemBuilder: (_, i) {
              final med = meds[i];
              return Card(
                child: ListTile(
                  title: Text('${med.name} (${med.dose})'),
                  subtitle: Text('Dosage: ${med.dosage}\nFrequency: ${med.frequency}'),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Mark Taken'),
                    onPressed: () {
                      final time = TimeOfDay.now().format(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Marked ${med.name} as taken at $time')),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
