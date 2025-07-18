import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/mood_tracker/mood_screen.dart';
import '../features/meds/meds_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/meds/meds_page.dart';
import '../features/meds/track_screen.dart';

final panRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => PanShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
        GoRoute(path: '/mood', builder: (context, state) => const MoodScreen()),
        GoRoute(path: '/meds', builder: (context, state) => const MedsScreen()),
        GoRoute(path: '/journal', builder: (context, state) => const JournalScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    ),
  ],
);

class PanShell extends StatelessWidget {
  final Widget child;
  const PanShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFromLocation(ModalRoute.of(context)?.settings.name ?? '/'),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/chat'); break;
            case 2: context.go('/mood'); break;
            case 3: context.go('/meds'); break;
            case 4: context.go('/journal'); break;
            case 5: context.go('/settings'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.mood), label: 'Mood'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Meds'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/mood')) return 2;
    if (location.startsWith('/meds')) return 3;
    if (location.startsWith('/journal')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0; // default: Home
  }
    }
  
