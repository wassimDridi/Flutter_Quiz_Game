import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/Theme.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quizzz/parameter/app_localizations.dart';
import 'package:quizzz/service/notificationService.dart';
import 'screen/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();   
  await Firebase.initializeApp(); 
  await NotificationService().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
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
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''), // English
            Locale('fr', ''), // French
            Locale('ar', ''), // Arabic
          ],
          locale: themeProvider.locale,
          home: WelcomeScreen(),
        );
      },
    );
  }
}
