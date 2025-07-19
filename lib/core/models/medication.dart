import 'package:hive/hive.dart';
import 'reminder_time.dart';
import 'package:flutter/material.dart'

part 'medication.g.dart';

@HiveType(typeId: 0)
class Medication {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String dose;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final String frequency;

  @HiveField(4)
  final List<ReminderTime> reminders;

  @HiveField(5)
  final String? notes;

  Medication({
    required this.name,
    required this.dose,
    required this.dosage,
    required this.frequency,
    required this.reminders,
    this.notes,
  });

  static ReminderTime timeOfDayToReminder(TimeOfDay tod) {
    return ReminderTime(hour: tod.hour, minute: tod.minute);
  }
}
