import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'track_screen.dart';

class MedsPage extends StatelessWidget {
  const MedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medication Overview")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('Pan Meds Menu', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add / Edit Medication'),
              onTap: () {
                context.go('/meds'); // goes to MedsScreen
              },
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Daily Check-In'),
              onTap: () {
                context.go('/meds/checkin');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Back to Home'),
              onTap: () {
                context.go('/');
              },
            ),
          ],
        ),
      ),
      body: const TrackScreen(), // default screen
    );
  }
}
