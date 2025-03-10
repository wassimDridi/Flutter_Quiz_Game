import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzz/screen/Score.dart';
import 'package:quizzz/screen/quiz.dart';
import 'package:quizzz/screen/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzz/screen/authentification.dart';
import 'package:quizzz/extensions/extensions.dart';

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

  final User? _user = FirebaseAuth.instance.currentUser;

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
          onQuizComplete: _saveScore,
        ),
      ),
    );
  }

  Future<void> _saveScore(int correctAnswers) async {
    if (_user == null) return;

    try {
      final userScoreRef = FirebaseFirestore.instance
          .collection('scores')
          .doc(_user!.email);

      final userScoreDoc = await userScoreRef.get();

      if (userScoreDoc.exists) {
        final currentScore = userScoreDoc['correctAnswers'] as int;
        final updatedScore = currentScore + correctAnswers;

        await userScoreRef.update({'correctAnswers': updatedScore});
      } else {
        await userScoreRef.set({
          'userEmail': _user!.email,
          'correctAnswers': correctAnswers,
          'numQuestions': _numQuestions,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('score_update_success'.tr(context)),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('score_update_failed'.tr(context)),
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
        title: Text('home_title'.tr(context)),
        backgroundColor: Colors.blueAccent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                _user?.email ?? 'guest_user'.tr(context),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'logout_tooltip'.tr(context),
            onPressed: _logout,
          ),
        ],
      ),
      body: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Text(
                    'num_questions_label'.tr(context),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<int>(
                    value: _numQuestions,
                    isExpanded: true,
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
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
                  Text(
                    'category_label'.tr(context),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    items: _categories.map((category) => DropdownMenuItem<String>(
                          value: category['name'],
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category['name']),
                                size: 24,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 10),
                              Text(
                                category['name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'difficulty_label'.tr(context),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: _selectedDifficulty,
                    isExpanded: true,
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
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
                  Center(
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        
                      ),
                      child: Text(
                        'start_game_button'.tr(context),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(child: Text('select_tab_label'.tr(context))),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home_tab'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'scores_tab'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings_tab'.tr(context),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'General Knowledge':
        return Icons.lightbulb;
      case 'Entertainment: Books':
        return Icons.book;
      case 'Entertainment: Film':
        return Icons.movie;
      case 'Entertainment: Music':
        return Icons.music_note;
      case 'Science & Nature':
        return Icons.nature;
      case 'Science: Computers':
        return Icons.computer;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Geography':
        return Icons.map;
      default:
        return Icons.category;
    }
  }
}
