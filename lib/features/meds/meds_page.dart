// lib/features/meds/meds_page.dart

import 'package:flutter/material.dart';
import 'meds_screen.dart'; // your current UI
import 'track_screen.dart'; // will add this next

class MedsPage extends StatefulWidget {
  const MedsPage({super.key});

  @override
  State<MedsPage> createState() => _MedsPageState();
}

class _MedsPageState extends State<MedsPage> {
  int _selectedIndex = 0;

  final _screens = const [
    MedsScreen(),
    TrackScreen(), // we'll implement this in the next step
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Track',
          ),
        ],
      ),
    );
  }
}
