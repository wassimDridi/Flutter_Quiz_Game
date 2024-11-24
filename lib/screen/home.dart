import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzz/parameter/app_localizations.dart';
import 'package:quizzz/screen/quiz.dart';
import 'package:quizzz/screen/settings.dart';

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
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      // Revenir à HomeScreen si on est déjà sur cet écran
      setState(() {
        _currentIndex = index;
      });
    } else if (index == 1) {
      // Aller à SettingsScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context).translate('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppLocalizations.of(context).translate('settings')),
        ],
      ),
    );
  }
}
