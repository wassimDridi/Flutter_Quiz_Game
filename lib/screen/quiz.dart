import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:quizzz/parameter/SettingsProvider.dart';
import 'package:quizzz/screen/SummaryScreen.dart';
import 'package:quizzz/extensions/extensions.dart'; // Import des extensions

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
  List<String> _userAnswers = [];

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
        _showError('failed_to_load_questions'.tr(context));
      }
    } catch (e) {
      _showError('failed_to_load_questions'.tr(context));
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.isSoundEnabled) {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
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
      _userAnswers.add(selectedAnswer ?? 'no_answer'.tr(context));

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
          title: Text('quiz_completed'.tr(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
  'your_score'.tr(context,args: ['$_score', '${_questions.length}']),
),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onQuizComplete(_score);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryScreen(
                        questions: _questions,
                        userAnswers: _userAnswers,
                      ),
                    ),
                  );
                },
                child: Text('back_to_home'.tr(context)),
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
          title: Text('error'.tr(context)),
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
        title: Text('quiz_in_progress'.tr(context)),
      ),
      body: _questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(

'remaining_time'.tr(context, args: ['${_timeLeft}']),
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
