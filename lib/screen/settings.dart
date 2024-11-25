import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';
import 'package:quizzz/parameter/Theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quizzz/screen/Score.dart';
import 'package:quizzz/screen/home.dart'; 

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 2; // Default to the Settings tab

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Theme settings
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Locale settings
    Locale currentLocale = themeProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr()),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings_Screen'.tr(), // Translated screen title
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Sound toggle
            SwitchListTile(
              title: Text('Enable_Sounds'.tr()), // Translated sound option
              value: settingsProvider.isSoundEnabled,
              onChanged: (value) {
                settingsProvider.toggleSound(value);
              },
            ),
            SizedBox(height: 20),
            // Dark mode toggle
            SwitchListTile(
              title: Text('Dark_Mode'.tr()), // Translated dark mode option
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            SizedBox(height: 20),
            // Language change
            Text('Change_Language'.tr()), // Translated text for language change
            DropdownButton<String>(
              value: currentLocale.languageCode,
              onChanged: (String? newLang) {
                if (newLang != null) {
                  themeProvider.setLocale(Locale(newLang));
                  context.setLocale(Locale(newLang)); // Update locale
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'.tr()), // Translated language name
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('Français'.tr()), // Translated language name
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('العربية'.tr()), // Translated language name
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home_tab'.tr(), // Translated tab name
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'scores_tab'.tr(), // Translated tab name
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings_tab'.tr(), // Translated tab name
          ),
        ],
      ),
    );
  }

  // Handle tab changes
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to Home
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScoreScreen()), // Navigate to Scores
        );
        break;
      case 2:
        // Stay on Settings screen
        break;
    }
  }
}
