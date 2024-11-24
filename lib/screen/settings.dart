import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';
import 'package:quizzz/parameter/Theme.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Theme settings
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Locale settings
    Locale currentLocale = themeProvider.locale;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Set "Settings" as the selected index
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: tr("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: tr("Settings"),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(tr('Settings')),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('Settings Screen'),
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Sound toggle
            SwitchListTile(
              title: Text(tr('Enable Sounds')),
              value: settingsProvider.isSoundEnabled,
              onChanged: (value) {
                settingsProvider.toggleSound(value);
              },
            ),
            SizedBox(height: 20),
            // Dark mode toggle
            SwitchListTile(
              title: Text(tr('Dark Mode')),
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            SizedBox(height: 20),
            // Language change
            Text(tr('Change Language:')),
            DropdownButton<String>(
              value: currentLocale.languageCode,
              onChanged: (String? newLang) {
                if (newLang != null) {
                  themeProvider.setLocale(Locale(newLang));
                  context.setLocale(Locale(newLang));
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('Français'),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('العربية'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
