
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Écran principal'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'Bienvenue dans le jeu ! Prêt à commencer?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
