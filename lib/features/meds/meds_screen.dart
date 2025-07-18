import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/medication.dart';
import '../../core/services/notification_service.dart';
import 'package:pan/features/meds/meds_provider.dart';

final medsBoxProvider = FutureProvider<Box<Medication>>((ref) async {
  return Hive.openBox<Medication>('medications');
});

class MedsScreen extends ConsumerStatefulWidget {
  const MedsScreen({super.key});

  @override
  ConsumerState<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends ConsumerState<MedsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();
  int? _editingIndex;
  bool _setReminder = false;
  TimeOfDay _reminderTime = TimeOfDay(hour: 8, minute: 0);

  void _pickReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveMedication(Box<Medication> box) async {
    if (_formKey.currentState!.validate()) {
      final med = Medication(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        remind: _setReminder,
        reminderTimeString: _setReminder
            ? Medication.formatTimeOfDay(_reminderTime)
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (_editingIndex != null) {
        final key = box.keyAt(_editingIndex!);
        await box.put(key, med);
      } else {
        await box.add(med);
      }

      if (_setReminder) {
        await NotificationService.scheduleDailyNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: 'Time to take ${med.name}',
          body: 'Dose: ${med.dose} • ${med.dosage}',
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
      }

      _formKey.currentState!.reset();
      _nameController.clear();
      _doseController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _notesController.clear();

      setState(() {
        _setReminder = false;
        _reminderTime = const TimeOfDay(hour: 8, minute: 0);
        _editingIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final medsBoxAsync = ref.watch(medsBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medication Tracker 💊')),
      body: medsBoxAsync.when(
        data: (box) {
          final meds = box.values.toList().reversed.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Medication Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter medication name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _doseController,
                        decoration: const InputDecoration(
                          labelText: 'Dose (e.g. 20mg)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _dosageController,
                        decoration: const InputDecoration(
                          labelText: 'Dosage (e.g. 1 tablet)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _frequencyController,
                        decoration: const InputDecoration(
                          labelText: 'Frequency (e.g. Daily)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Optional Notes (How you feel)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Set Daily Reminder?'),
                        value: _setReminder,
                        onChanged: (val) {
                          setState(() => _setReminder = val);
                        },
                      ),
                      if (_setReminder)
                        Row(
                          children: [
                            Text('Time: ${_reminderTime.format(context)}'),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _pickReminderTime(context),
                              child: const Text('Pick Time'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _saveMedication(box),
                        icon: const Icon(Icons.save),
                        label: const Text('Add Medication'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Text('Your Medications:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...meds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final med = entry.value;

                  return Dismissible(
                    key: Key(med.key.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      await box.delete(med.key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${med.name} deleted')),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _editingIndex = index;
                            _nameController.text = med.name;
                            _doseController.text = med.dose;
                            _dosageController.text = med.dosage;
                            _frequencyController.text = med.frequency;
                            _notesController.text = med.notes ?? '';
                            _setReminder = med.remind;
                            _reminderTime = med.reminderTime ?? const TimeOfDay(hour: 8, minute: 0);
                          });
                        },
                        title: Text('${med.name} (${med.dose})'),
                        subtitle: Text('Dosage: ${med.dosage}\n'
                            'Frequency: ${med.frequency}'
                            '${med.remind && med.reminderTime != null ? '\nReminder: ${med.reminderTime!.format(context)}' : ''}'
                            '${med.notes != null ? '\nNote: ${med.notes}' : ''}'),
                        trailing: const Icon(Icons.edit),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
