import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/models/mood_entry.dart';
import 'core/models/reminder_time.dart';
import 'core/models/med_log.dart'
import 'core/models/medication.dart';
import 'core/services/notification_service.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(ReminderTimeAdapter());
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(MedLogAdapter());


  await Hive.openBox<Medication>('medications');
  await Hive.openBox<MedLog>('med_logs');

  // Initialize local notifications
  await NotificationService.init();

  // Launch app with Riverpod scope
  runApp(const ProviderScope(child: PanApp()));
}

class PanApp extends StatelessWidget {
  const PanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: PanTheme.light,
      darkTheme: PanTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: panRouter,
    );
  }
}
