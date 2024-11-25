import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/Theme.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quizzz/parameter/app_localizations.dart';
import 'package:quizzz/screen/authentification.dart';
import 'package:quizzz/screen/inscription.dart';
import 'package:quizzz/service/notificationService.dart';
import 'screen/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final routes = {
      '/auth': (context) => AuthentificationPage(),
      '/insc': (context) => InscriptionPage(),
      '/welcome': (context) => WelcomeScreen(),
    };
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          routes: routes,
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
          home: _AuthChecker(),
        );
      },
    );
  }
}


class _AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est déjà authentifié
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Si l'utilisateur est connecté, aller directement à la page d'accueil
      return WelcomeScreen();
    } else {
      // Sinon, rediriger vers la page d'authentification
      return AuthentificationPage();
    }
  }
}