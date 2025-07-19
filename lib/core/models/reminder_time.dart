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

  TimeOfDay toTimeOfDay() {
  return TimeOfDay(hour: hour, minute: minute);
  }

  String formatted(BuildContext context) {
    final time = toTimeOfDay();
    return TimeOfDayFormat.H_colon_mm == MediaQuery.of(context).alwaysUse24HourFormat
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : time.format(context);
  }
}
