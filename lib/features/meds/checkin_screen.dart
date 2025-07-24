import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pan Check-In 🌱')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _CheckInTile(
              icon: Icons.medical_services,
              label: 'Log Meds',
              onTap: () => context.push('/meds'),
            ),
            _CheckInTile(
              icon: Icons.check_circle,
              label: 'Take Meds',
              onTap: () => context.push('/meds'),
            ),
            _CheckInTile(
              icon: Icons.mood,
              label: 'Log Mood',
              onTap: () => context.push('/mood'),
            ),
            _CheckInTile(
              icon: Icons.book,
              label: 'Journal',
              onTap: () => context.push('/journal'),
            ),
            _CheckInTile(
              icon: Icons.chat_bubble,
              label: 'Talk to Pan',
              onTap: () => context.push('/chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CheckInTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(label, style: Theme.of(context).textTheme.bodyLarge)
            ],
          ),
        ),
      ),
    );
  }
}
