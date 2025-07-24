import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reminder_time.g.dart';

@HiveType(typeId: 1)
class ReminderTime {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  ReminderTime({required this.hour, required this.minute});

  static ReminderTime fromTimeOfDay(TimeOfDay tod) {
    return ReminderTime(hour: tod.hour, minute: tod.minute);
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatted(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(toTimeOfDay());
  }

  DateTime toDateTime(DateTime baseDate) {
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

}
