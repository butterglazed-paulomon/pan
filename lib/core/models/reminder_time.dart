import 'package:hive/hive.dart';

part 'reminder_time.g.dart';

@HiveType(typeId: 3)
class ReminderTime {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  ReminderTime(this.hour, this.minute);

  String format() {
    final time = TimeOfDay(hour: hour, minute: minute);
    final localizations = MaterialLocalizations.of(navigatorKey.currentContext!);
    return localizations.formatTimeOfDay(time);
  }

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
