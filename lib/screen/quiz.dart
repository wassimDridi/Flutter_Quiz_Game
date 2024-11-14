wimport 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String selectedCategory;
  final String selectedDifficulty;
  final int categoryId;

  QuizScreen({
    required this.numQuestions,
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.categoryId,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  Timer? _timer;
  int _timeLeft = 10;
  List<String> _answers = [];
  List<dynamic> _questions = [];
  Map<String, Color> _answerColors = {};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    String apiUrl =
        'https://opentdb.com/api.php?amount=${widget.numQuestions}&category=${widget.categoryId}&difficulty=${widget.selectedDifficulty}&type=multiple';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = data['results'];
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

    // Initialiser les couleurs des réponses
    _answerColors = {for (var answer in _answers) answer: Colors.blueAccent};
  }

  void _handleAnswer(String? selectedAnswer) {
    _stopTimer();
    setState(() {
      _isAnswered = true;

      String correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];

      // Définir les couleurs pour toutes les mauvaises réponses en rouge et la bonne réponse en vert
      for (var answer in _answers) {
        _answerColors[answer] = (answer == correctAnswer) ? Colors.green : Colors.red;
      }

      if (selectedAnswer == correctAnswer) {
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Retour à l'écran d'accueil
                },
                child: Text('Retour à l\'accueil'),
              ),
            ],
          ),
        );
      },
    );
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
        title: Text('Quiz en cours'),
      ),
      body: _questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Temps restant: $_timeLeft sec',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _questions[_currentQuestionIndex]['question'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ..._answers.map((answer) => GestureDetector(
                        onTap: _isAnswered ? null : () => _handleAnswer(answer),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _answerColors[answer],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              answer,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
