import 'package:flutter/material.dart';
import 'package:quizzz/screen/home.dart';
import 'package:quizzz/widget/featureContainer.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Bienvenue dans le Quiz Game'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Découvrez le jeu et ses caractéristiques!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FeatureContainerWidget(
                  color: Colors.black,
                  image: 'assets/difficulté.png',
                  title: 'Qu\'est-ce que le Quiz Game?',
                  description:
                      'Testez vos connaissances dans différentes catégories!',
                ),
                FeatureContainerWidget(
                  color: Colors.blue,
                  image: 'assets/difficulté.png',
                  title: 'Choix des catégories',
                  description:
                      'Sélectionnez parmi de nombreuses catégories de quiz.',
                ),
                FeatureContainerWidget(
                  color: Colors.green,
                  image: 'assets/difficulté.png',
                  title: 'Niveaux de difficulté',
                  description: 'Jouez avec différents niveaux de difficulté.',
                ),
                FeatureContainerWidget(
                  color: Colors.orange,
                  image: 'assets/challenge.jpg',
                  title: 'Chronomètre',
                  description:
                      'Répondez dans le temps imparti pour plus de challenge!',
                ),
                FeatureContainerWidget(
                  color: Colors.purple,
                  image: 'assets/score.png',
                  title: 'Système de Score',
                  description: 'Accédez à vos scores et classements.',
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(
              'Commencer le jeu',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Apply a fade transition effect
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
