import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reminder_time.g.dart';

@HiveType(typeId: 1)
class ReminderTime {
  @HiveField(0)
  int hour;

  @HiveField(1)
  int minute;

  ReminderTime({required this.hour, required this.minute});

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  static ReminderTime fromTimeOfDay(TimeOfDay time) =>
      ReminderTime(hour: time.hour, minute: time.minute);

  String format() {
    final t = toTimeOfDay();
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $suffix';
  }
}
