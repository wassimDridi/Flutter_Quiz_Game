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
import 'package:easy_localization/easy_localization.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();   
  await Firebase.initializeApp(); 
  await NotificationService().initNotifications();
  await EasyLocalization.ensureInitialized(); 

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
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          showSemanticsDebugger: false,

          routes: routes,
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('fr', ''), // French
            Locale('ar', ''), // Arabic
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
          
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return WelcomeScreen();
    } else {
      return AuthentificationPage();
    }
  }
}