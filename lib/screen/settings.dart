import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/Theme.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Définir l'index sur 1 pour afficher "Settings" comme actif
        onTap: (index) {
          if (index == 0) {
            // Revenir à HomeScreen si "Home" est sélectionné
            Navigator.pop(context);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings Screen',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Mode Sombre'),
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
