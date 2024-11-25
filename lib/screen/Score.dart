import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final User? _user = FirebaseAuth.instance.currentUser; // Current authenticated user
  int _currentUserScore = 0;
  List<Map<String, dynamic>> _scores = [];

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
    try {
      // Fetch all scores from Firestore
      final scoresSnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .orderBy('correctAnswers', descending: true)
          .get();

      final scores = scoresSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userEmail': data['userEmail'] ?? 'Unknown',
          'correctAnswers': data['correctAnswers'] ?? 0,
        };
      }).toList();

      // Find the authenticated user's score
      final currentUserScore = scores.firstWhere(
        (score) => score['userEmail'] == _user?.email,
        orElse: () => {'correctAnswers': 0},
      )['correctAnswers'];

      setState(() {
        _scores = scores;
        _currentUserScore = currentUserScore;
      });
    } catch (e) {
      print('Error fetching scores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display current user's score
            Text(
              'Votre score : $_currentUserScore',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Display all users' scores in a sorted list
            Text(
              'Classement des utilisateurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Expanded(
              child: _scores.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _scores.length,
                      itemBuilder: (context, index) {
                        final score = _scores[index];
                        return ListTile(
                          leading: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 18),
                          ),
                          title: Text(score['userEmail']),
                          trailing: Text(
                            '${score['correctAnswers']}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
