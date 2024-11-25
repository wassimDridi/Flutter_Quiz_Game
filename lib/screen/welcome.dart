import 'package:flutter/material.dart';
import 'package:quizzz/screen/home.dart';
import 'package:quizzz/widget/featureContainer.dart';
import 'package:quizzz/extensions/extensions.dart'; // Importez le fichier extensions.dart

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('welcome_title'.tr(context)), // Localisation du titre
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        // Permet le défilement vertical
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Espace supérieur
            Text(
              'welcome_subtitle'.tr(context), // Localisation du sous-titre
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Container(
              height: 300, // Garde la liste horizontale contenue
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FeatureContainerWidget(
                    color: Colors.black,
                    image: 'assets/difficulté.png',
                    title: 'feature_quiz_game_title'.tr(context), // Titre localisé
                    description: 'feature_quiz_game_description'.tr(context), // Description localisée
                  ),
                  FeatureContainerWidget(
                    color: Colors.blue,
                    image: 'assets/difficulté.png',
                    title: 'feature_categories_title'.tr(context), // Titre localisé
                    description: 'feature_categories_description'.tr(context), // Description localisée
                  ),
                  FeatureContainerWidget(
                    color: Colors.green,
                    image: 'assets/difficulté.png',
                    title: 'feature_difficulty_title'.tr(context), // Titre localisé
                    description: 'feature_difficulty_description'.tr(context), // Description localisée
                  ),
                  FeatureContainerWidget(
                    color: Colors.orange,
                    image: 'assets/challenge.jpg',
                    title: 'feature_timer_title'.tr(context), // Titre localisé
                    description: 'feature_timer_description'.tr(context), // Description localisée
                  ),
                  FeatureContainerWidget(
                    color: Colors.purple,
                    image: 'assets/score.png',
                    title: 'feature_score_title'.tr(context), // Titre localisé
                    description: 'feature_score_description'.tr(context), // Description localisée
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
                'start_game_button'.tr(context), // Texte du bouton localisé
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20), // Espace inférieur
          ],
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Effet de transition en fondu
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
