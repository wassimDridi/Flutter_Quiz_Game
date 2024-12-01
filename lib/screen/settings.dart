import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';
import 'package:quizzz/parameter/Theme.dart';
import 'package:quizzz/extensions/extensions.dart'; // Import the .tr extension
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
        title: Text('Settings'.tr(context)), // Use translated text
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings Screen'.tr(context), // Use translated text
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Sound toggle
            SwitchListTile(
              title: Text('Enable Sounds'.tr(context)), // Use translated text
              value: settingsProvider.isSoundEnabled,
              onChanged: (value) {
                settingsProvider.toggleSound(value);
              },
            ),
            SizedBox(height: 20),
            // Dark mode toggle
            SwitchListTile(
              title: Text('Dark Mode'.tr(context)), // Use translated text
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            SizedBox(height: 20),
            // Language change
            Text('Change Language'.tr(context)), // Use translated text
            DropdownButton<String>(
              value: currentLocale.languageCode,
              onChanged: (String? newLang) {
                if (newLang != null) {
                  themeProvider.setLocale(Locale(newLang));
                 // context.setLocale(Locale(newLang)); // Update locale
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('english'.tr(context)), // Use translated text
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('french'.tr(context)), // Use translated text
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('arabic'.tr(context)), // Use translated text
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
            label: 'home_tab'.tr(context), // Use translated text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'scores_tab'.tr(context), // Use translated text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings_tab'.tr(context), // Use translated text
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
