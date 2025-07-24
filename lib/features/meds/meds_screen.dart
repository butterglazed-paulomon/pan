import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/medication.dart';
import '../../core/models/reminder_time.dart';
import '../../core/models/med_log.dart';
import '../../core/services/notification_service.dart';

class MedsScreen extends ConsumerStatefulWidget {
  const MedsScreen({super.key});

  @override
  ConsumerState<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends ConsumerState<MedsScreen> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();
  List<ReminderTime> _reminders = [];

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

  void _showMedicationForm(Box<Medication> box, [int? editKey]) {
    if (editKey != null) {
      final med = box.get(editKey);
      if (med != null) {
        _nameController.text = med.name;
        _doseController.text = med.dose;
        _dosageController.text = med.dosage;
        _frequencyController.text = med.frequency;
        _notesController.text = med.notes ?? '';
        _reminders = List.from(med.reminders);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g. Paracetamol',
                ),
              ),
              TextField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  hintText: 'e.g. 500mg',
                ),
              ),
              TextField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 1 tablet',
                ),
              ),
              TextField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  hintText: 'e.g. Twice a day',
                ),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'e.g. After meals',
                ),
              ),
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Add Reminder Time'),
              ),
              Column(
                children: _reminders.map((r) => ListTile(
                  title: Text(r.formatted(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _reminders.remove(r);
                      });
                    },
                  ),
                )).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  final med = Medication(
                    name: _nameController.text,
                    dose: _doseController.text,
                    dosage: _dosageController.text,
                    frequency: _frequencyController.text,
                    notes: _notesController.text,
                    reminders: _reminders,
                  );

                  if (editKey != null) {
                    await box.put(editKey, med);
                  } else {
                    final key = await box.add(med);

                    for (final reminder in _reminders) {
                      final tod = reminder.toTimeOfDay();
                      await NotificationService.scheduleDailyNotification(
                        id: DateTime.now().millisecondsSinceEpoch % 100000,
                        title: 'Take ${med.name}',
                        body: 'Dose: ${med.dose} • ${med.dosage}',
                        hour: tod.hour,
                        minute: tod.minute,
                      );
                    }
                  }

                  _nameController.clear();
                  _doseController.clear();
                  _dosageController.clear();
                  _frequencyController.clear();
                  _notesController.clear();
                  _reminders.clear();
                  Navigator.pop(context);
                },
                child: const Text('Save Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logMedication(int medKey, ReminderTime reminderTime) async {
    final box = await Hive.openBox<MedLog>('med_logs');
    final now = DateTime.now();
    await box.add(MedLog(
      medicationKey: medKey,
      takenTime: now,
      scheduledTime: reminderTime.toDateTime(now),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final medsBox = Hive.box<Medication>('medications');
    final logsBox = Hive.box<MedLog>('med_logs');

    return Scaffold(
      appBar: AppBar(title: const Text('Medication Tracker 💊')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMedicationForm(medsBox),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: logsBox.listenable(),
        builder: (context, Box<MedLog> logs, _) {
          final today = DateTime.now();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: medsBox.toMap().entries.map((entry) {
              final key = entry.key as int;
              final med = entry.value;

              final takenToday = logs.values.any((log) =>
                log.medicationKey == key &&
                log.takenTime?.year == today.year &&
                log.takenTime?.month == today.month &&
                log.takenTime?.day == today.day);

              return Dismissible(
                key: ValueKey(key),
                background: Container(
                  color: Colors.orange,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    _showMedicationForm(medsBox, key);
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    medsBox.delete(key);
                    return true;
                  }
                  return false;
                },
                child: Card(
                  child: ListTile(
                    title: Text('${med.name} (${med.dose})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dosage: ${med.dosage}'),
                        Text('Frequency: ${med.frequency}'),
                        if (med.notes != null) Text('Notes: ${med.notes}')
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        takenToday ? Icons.check_circle : Icons.check_circle_outline,
                        color: takenToday ? Colors.green : null,
                      ),
                      onPressed: takenToday
                        ? null
                        : () => _logMedication(key, med.reminders.first),
                    ),
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
