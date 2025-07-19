import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/medication.dart';
import '../../core/models/reminder_time.dart';
import '../../core/models/med_log.dart';
import '../../core/services/notification_service.dart';

final medsBoxProvider = FutureProvider<Box<Medication>>((ref) async {
  return Hive.openBox<Medication>('medications');
});

final medLogBoxProvider = FutureProvider<Box<MedLog>>((ref) async {
  return Hive.openBox<MedLog>('med_logs');
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
  bool _useInterval = false;
  int _intervalHours = 24;

  List<ReminderTime> _reminders = [];
  int? _editingKey;

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _reminders.add(ReminderTime.fromTimeOfDay(picked));
      });
    }
  }

  Future<void> _saveMedication(Box<Medication> box) async {
    if (_formKey.currentState!.validate()) {
      final med = Medication(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        reminders: _reminders,
      );

      if (_editingKey != null) {
        final oldMed = box.get(_editingKey);
        if (oldMed != null) {
          await NotificationService.cancelNotificationsForMedication(
            _editingKey!,
            _useInterval ? 1 : oldMed.reminders.length,
          );
        }
      }

      if (_useInterval) {
        final intervalId = DateTime.now().millisecondsSinceEpoch % 100000;
        await NotificationService.scheduleRepeatingNotification(
          id: intervalId,
          title: 'Take ${_nameController.text.trim()}',
          body: 'Dose: ${_doseController.text.trim()} • ${_dosageController.text.trim()}',
          intervalHours: _intervalHours,
        );
      } else {
        for (final reminder in _reminders) {
          final tod = reminder.toTimeOfDay();
          await NotificationService.scheduleDailyNotification(
            id: DateTime.now().millisecondsSinceEpoch % 100000,
            title: 'Time to take ${_nameController.text.trim()}',
            body: 'Dose: ${_doseController.text.trim()} • ${_dosageController.text.trim()}',
            hour: tod.hour,
            minute: tod.minute,
          );
        }
      }

      _formKey.currentState!.reset();
      _nameController.clear();
      _doseController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _notesController.clear();
      setState(() {
        _reminders = [];
        _editingKey = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final medsBoxAsync = ref.watch(medsBoxProvider);
    final logBoxAsync = ref.watch(medLogBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medication Tracker 💊')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/meds/checkin'),
        child: const Icon(Icons.add),
      ),
      body: medsBoxAsync.when(
        data: (box) {
          final entries = box.toMap().entries.toList().reversed;

          return logBoxAsync.when(
            data: (logBox) {
              final today = DateTime.now();
              final todayLogs = logBox.values.where((log) {
                return log.timestamp.year == today.year &&
                    log.timestamp.month == today.month &&
                    log.timestamp.day == today.day;
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      color: Colors.blue.shade50,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: const Text("Doses Taken Today"),
                        subtitle: Text("${todayLogs.length} doses logged on July 19, 2025"),
                      ),
                    ),
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
                            title: const Text("Use interval-based reminder (e.g., every X hours)"),
                            value: _useInterval,
                            onChanged: (value) {
                              setState(() {
                                _useInterval = value;
                              });
                            },
                          ),
                          if (_useInterval)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                initialValue: _intervalHours.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Interval (hours)'),
                                validator: (value) {
                                  final val = int.tryParse(value ?? '');
                                  if (val == null || val <= 0) {
                                    return 'Enter a valid number > 0';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _intervalHours = int.tryParse(value) ?? 24;
                                  });
                                },
                              ),
                            )
                          else
                            Row(
                              children: [
                                const Text('Reminders:'),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _pickTime,
                                  child: const Text('Add Reminder Time'),
                                ),
                              ],
                            ),
                          Column(
                            children: _reminders
                                .map((reminder) => ListTile(
                                      title: Text(reminder.formatted(context)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            _reminders.remove(reminder);
                                          });
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => _saveMedication(box),
                            icon: const Icon(Icons.save),
                            label: Text(_editingKey != null
                                ? 'Update Medication'
                                : 'Add Medication'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      'Your Medications:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...entries.map((entry) {
                      final key = entry.key;
                      final med = entry.value;

                      return Dismissible(
                        key: Key('$key'),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await box.delete(key);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${med.name} deleted')),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _editingKey = key;
                                _nameController.text = med.name;
                                _doseController.text = med.dose;
                                _dosageController.text = med.dosage;
                                _frequencyController.text = med.frequency;
                                _notesController.text = med.notes ?? '';
                                _reminders = List.from(med.reminders);
                              });
                            },
                            title: Text('${med.name} (${med.dose})'),
                            subtitle: Text(
                              'Dosage: ${med.dosage}\n'
                              'Frequency: ${med.frequency}'
                              '${med.reminders.isNotEmpty ? '\nReminder: ${med.reminders.map((r) => r.formatted(context)).join(', ')}' : ''}'
                              '${med.notes != null ? '\nNote: ${med.notes}' : ''}',
                            ),
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
            error: (e, _) => Center(child: Text('Error loading logs: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
