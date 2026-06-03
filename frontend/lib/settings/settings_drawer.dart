import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    required this.isDarkMode,
    required this.onDarkModeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Use the dark app theme'),
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: isDarkMode,
              onChanged: onDarkModeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
