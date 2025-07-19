import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/models/med_log.dart';
import 'core/models/medication.dart';
import 'core/models/reminder_time.dart';
import 'core/services/notification_service.dart';
import 'app/router.dart'; // panRouter
import 'app/theme.dart'; // PanTheme

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(ReminderTimeAdapter());
  Hive.registerAdapter(MedLogAdapter());

  await Hive.openBox<Medication>('medications');
  await Hive.openBox<MedLog>('med_logs');

  await NotificationService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: panRouter,
      theme: PanTheme.light,
      darkTheme: PanTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
