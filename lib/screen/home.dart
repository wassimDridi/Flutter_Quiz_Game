import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzz/screen/Score.dart';
import 'package:quizzz/screen/quiz.dart';
import 'package:quizzz/screen/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzz/screen/authentification.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _numQuestions = 10;
  String _selectedCategory = 'General Knowledge';
  String _selectedDifficulty = 'easy';
  List<dynamic> _categories = [];
  final List<int> _questionNumbers = [3, 5, 7, 10, 15];
  final List<String> _difficultyLevels = ['easy', 'medium', 'hard'];
  int _currentIndex = 0;

  final User? _user = FirebaseAuth.instance.currentUser; // Current authenticated user

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _categories = data['trivia_categories'];
      });
    }
  }

  void _startQuiz() {
    int categoryId = _categories.firstWhere((cat) => cat['name'] == _selectedCategory)['id'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          numQuestions: _numQuestions,
          selectedCategory: _selectedCategory,
          selectedDifficulty: _selectedDifficulty,
          categoryId: categoryId,
          onQuizComplete: _saveScore, // Callback to save score
        ),
      ),
    );
  }

  Future<void> _saveScore(int correctAnswers) async {
    if (_user == null) return; // Ensure user is authenticated

    try {
      // Reference to the user's score document
      final userScoreRef = FirebaseFirestore.instance
          .collection('scores')
          .doc(_user!.email); // Use email as document ID for uniqueness

      final userScoreDoc = await userScoreRef.get();

      if (userScoreDoc.exists) {
        // If the document exists, update the score by adding the new correctAnswers
        final currentScore = userScoreDoc['correctAnswers'] as int;
        final updatedScore = currentScore + correctAnswers;

        await userScoreRef.update({'correctAnswers': updatedScore});
      } else {
        // If the document does not exist, create a new score record
        await userScoreRef.set({
          'userEmail': _user!.email,
          'correctAnswers': correctAnswers,
          'numQuestions': _numQuestions,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Score updated successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update score: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthentificationPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScoreScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Center(
            child: Text(
              _user?.email ?? 'Guest',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text('Nombre de Questions:', style: TextStyle(fontSize: 18)),
                  DropdownButton<int>(
                    value: _numQuestions,
                    items: _questionNumbers.map((num) => DropdownMenuItem<int>(
                          value: num,
                          child: Text('$num'),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _numQuestions = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Catégorie:', style: TextStyle(fontSize: 18)),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((category) => DropdownMenuItem<String>(
                          value: category['name'],
                          child: Text(category['name']),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Difficulté:', style: TextStyle(fontSize: 18)),
                  DropdownButton<String>(
                    value: _selectedDifficulty,
                    items: _difficultyLevels.map((difficulty) => DropdownMenuItem<String>(
                          value: difficulty,
                          child: Text(difficulty),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _startQuiz,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Début du jeu',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            )
          : Center(child: Text('Select a tab.')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'Scores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
