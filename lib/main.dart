import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pan/features/meds/meds_screen.dart';


import 'core/models/mood_entry.dart';
import 'core/models/reminder_time.dart';
import 'core/models/med_log.dart';
import 'core/models/medication.dart';
import 'core/services/notification_service.dart';
import 'app/router.dart';
import 'app/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(ReminderTimeAdapter());

  await Hive.openBox<Medication>('medications');
  await Hive.openBox<MedLog>('med_logs');
  await NotificationService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Pan Mental Health Companion',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: MedsScreen(),
    );
  }
}