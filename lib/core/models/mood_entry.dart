import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int mood; // 1-10 scale

  @HiveField(2)
  final String? note;

  MoodEntry({
    required this.date,
    required this.mood,
    this.note,
  });
}
