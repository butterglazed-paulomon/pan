import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 0)
class Medication extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String dose;

  @HiveField(2)
  String dosage;

  @HiveField(3)
  String frequency;

  @HiveField(4)
  List<ReminderTime> reminders; // New: multiple times per day

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  Medication({
    required this.name,
    required this.dose,
    required this.dosage,
    required this.frequency,
    required this.reminders,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
