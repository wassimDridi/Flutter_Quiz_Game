import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/Theme.dart';
import 'package:quizzz/screen/welcome.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: WelcomeScreen(),
        );
      },
    );
  }
}
