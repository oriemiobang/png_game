import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:png_game/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes.'),
            value: isDark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          // More settings can be added here
        ],
      ),
    );
  }
}
