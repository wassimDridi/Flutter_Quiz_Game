import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String selectedCategory;
  final String selectedDifficulty;
  final int categoryId;
  final Function(int correctAnswers) onQuizComplete;

  QuizScreen({
    required this.numQuestions,
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.categoryId,
    required this.onQuizComplete,
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

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    String apiUrl =
        'https://opentdb.com/api.php?amount=${widget.numQuestions}&category=${widget.categoryId}&difficulty=${widget.selectedDifficulty}&type=multiple';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _questions = data['results'];
        });
        _startTimer();
        _prepareAnswers();
      } else {
        _showError('Failed to load questions. Please try again later.');
      }
    } catch (e) {
      _showError('An error occurred while fetching questions.');
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

  Future<void> _playSound(String soundFile) async {
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.isSoundEnabled) {
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.play(AssetSource('sounds/$soundFile'));
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _prepareAnswers() {
    final currentQuestion = _questions[_currentQuestionIndex];
    _answers = [...currentQuestion['incorrect_answers']];
    _answers.add(currentQuestion['correct_answer']);
    _answers.shuffle(Random());

    _answerColors = {for (var answer in _answers) answer: Colors.blueAccent};
  }

  void _handleAnswer(String? selectedAnswer) {
    _stopTimer();
    setState(() {
      _isAnswered = true;

      String correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];

      _answerColors = {
        for (var answer in _answers)
          answer: (answer == correctAnswer) ? Colors.green : Colors.red,
      };

      if (selectedAnswer == correctAnswer) {
        _score++;
        _playSound('correct.mp3');
      } else {
        _playSound('wrong.mp3');
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
    String soundFile = _score >= (_questions.length / 2) ? 'happy.mp3' : 'sad.mp3';
    _playSound(soundFile);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz terminé'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Votre score: $_score/${_questions.length}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onQuizComplete(_score);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Retour à l\'accueil'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
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
