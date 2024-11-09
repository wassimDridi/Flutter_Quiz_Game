import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzz/screen/quiz.dart';

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
    );
  }
}



/* 
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _numQuestions = 10;
  String _selectedCategory = 'General Knowledge';
  String _selectedDifficulty = 'easy';
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  Timer? _timer;
  int _timeLeft = 10;
  List<String> _answers = []; // Stocke les réponses pour la question actuelle

  List<dynamic> _categories = [];
  List<dynamic> _questions = [];

  // Options possibles
  final List<int> _questionNumbers = [5, 10, 15, 20, 25, 30];
  final List<String> _difficultyLevels = ['easy', 'medium', 'hard'];

  // Récupérer les catégories depuis l'API OpenTDB
  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _categories = data['trivia_categories'];
      });
    }
  }

  // Récupérer les questions de l'API selon les paramètres sélectionnés
  Future<void> _fetchQuestions() async {
    int categoryId = _categories.firstWhere((cat) => cat['name'] == _selectedCategory)['id'];
    String apiUrl =
        'https://opentdb.com/api.php?amount=$_numQuestions&category=$categoryId&difficulty=$_selectedDifficulty&type=multiple';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = data['results'];
        _currentQuestionIndex = 0;
        _score = 0;
      });
      _startTimer();
      _prepareAnswers();
    } else {
      print('Failed to load questions');
    }
  }

  void _startTimer() {
    _timeLeft = 10;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _handleAnswer(null);
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _prepareAnswers() {
    final currentQuestion = _questions[_currentQuestionIndex];
    _answers = [...currentQuestion['incorrect_answers']];
    _answers.add(currentQuestion['correct_answer']);
    _answers.shuffle(Random());
  }

  void _handleAnswer(String? selectedAnswer) {
    _stopTimer();
    setState(() {
      _isAnswered = true;

      if (selectedAnswer == _questions[_currentQuestionIndex]['correct_answer']) {
        _score++;
      }

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isAnswered = false;
          if (_currentQuestionIndex < _questions.length - 1) {
            _currentQuestionIndex++;
            _prepareAnswers();
            _startTimer();
          } else {
            _showResult();
          }
        });
      });
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz terminé'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Votre score: $_score/${_questions.length}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchQuestions(); // Relancer le quiz
                },
                child: Text('Rejouer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Accueil'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        child: _questions.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue dans le jeu ! Prêt à commencer?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Text('Nombre de Questions:', style: TextStyle(fontSize: 18)),
                  DropdownButton<int>(
                    value: _numQuestions,
                    items: _questionNumbers
                        .map((num) => DropdownMenuItem<int>(
                              value: num,
                              child: Text('$num'),
                            ))
                        .toList(),
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
                    items: _categories
                        .map((category) => DropdownMenuItem<String>(
                              value: category['name'],
                              child: Text(category['name']),
                            ))
                        .toList(),
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
                    items: _difficultyLevels
                        .map((difficulty) => DropdownMenuItem<String>(
                              value: difficulty,
                              child: Text(difficulty),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: _fetchQuestions,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        'Début du jeu',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Text(
                    'Temps restant: $_timeLeft sec',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _questions[_currentQuestionIndex]['question'],
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ..._answers.map((answer) {
                    return GestureDetector(
                      onTap: _isAnswered ? null : () => _handleAnswer(answer),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: _isAnswered && answer == _questions[_currentQuestionIndex]['correct_answer']
                              ? Colors.green
                              : _isAnswered && answer != _questions[_currentQuestionIndex]['correct_answer']
                                  ? Colors.red
                                  : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            answer,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
 */