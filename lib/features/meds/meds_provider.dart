import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/models/medication.dart';
import '../../core/models/med_log.dart';

final medsBoxProvider = FutureProvider<Box<Medication>>((ref) async {
  return Hive.openBox<Medication>('medications');
});

final medLogsBoxProvider = FutureProvider<Box<MedLog>>((ref) async {
  return Hive.openBox<MedLog>('med_logs');
});
