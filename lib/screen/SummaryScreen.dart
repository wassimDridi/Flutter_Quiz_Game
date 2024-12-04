import 'package:flutter/material.dart';
import 'package:quizzz/extensions/extensions.dart';

class SummaryScreen extends StatelessWidget {
  final List<dynamic> questions;
  final List<String> userAnswers;

  SummaryScreen({
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('summary_title'.tr(context)),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
            Navigator.pop(context);
          },
          tooltip: 'Back',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final correctAnswer = question['correct_answer'];
            final userAnswer = userAnswers[index];
            final isCorrect = userAnswer == correctAnswer;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              color: isCorrect ? Colors.green[50] : Colors.red[50],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'question_number'.tr(
                        context,
                        args: ['${index + 1}', question['question']],
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'your_answer'.tr(context, args: [userAnswer]),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'correct_answer'.tr(context, args: [correctAnswer]),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
