import 'package:hive/hive.dart';

part 'med_log.g.dart';

@HiveType(typeId: 2)
class MedLog extends HiveObject {
  @HiveField(0)
  int medicationKey;

  @HiveField(1)
  DateTime scheduledTime;

  @HiveField(2)
  DateTime? takenTime;

  @HiveField(3)
  bool taken;

  @HiveField(4)
  String? notes;

  MedLog({
    required this.medicationKey,
    required this.scheduledTime,
    this.takenTime,
    this.notes,
    this.taken = false,
  });
}
