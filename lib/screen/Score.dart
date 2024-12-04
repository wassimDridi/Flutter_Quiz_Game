import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizzz/screen/home.dart'; // Import HomeScreen
import 'package:quizzz/extensions/extensions.dart';
import 'package:quizzz/screen/settings.dart'; // Import translation extension

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final User? _user = FirebaseAuth.instance.currentUser; // Current authenticated user
  int _currentUserScore = 0;
  List<Map<String, dynamic>> _scores = [];
  int _currentIndex = 1; // Default to the Scores tab

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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to Home
        );
        break;
      case 1:
      // Stay on the Scores screen
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()), // Navigate to Settings
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scores_title'.tr(context)), // Use translated text
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display current user's score
            Text(
              'your_score1'.tr(context , args: [_currentUserScore.toString()]),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Display all users' scores in a sorted list
            Text(
              'user_ranking'.tr(context),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home_tab'.tr(context), // Use translated text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'scores_tab'.tr(context), // Use translated text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings_tab'.tr(context), // Use translated text
          ),
        ],
      ),
    );
  }
}
