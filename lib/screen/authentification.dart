import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../extensions/extensions.dart'; // Importer l'extension .tr
import 'package:quizzz/parameter/app_localizations.dart';

class AuthentificationPage extends StatelessWidget {
  final TextEditingController txt_login = TextEditingController();
  final TextEditingController txt_password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auth_page_title'.tr(context)), // Traduction du titre
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: txt_login,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: "user_hint".tr(context), // Traduction du placeholder
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: txt_password,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: "password_hint".tr(context), // Traduction du placeholder
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                _onAuthentifier(context);
              },
              child: Text('login_button'.tr(context), style: TextStyle(fontSize: 22)), // Traduction du bouton
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/insc');
            },
            child: Text(
              "new_user".tr(context), // Traduction du texte
              style: TextStyle(fontSize: 22),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _onAuthentifier(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: txt_login.text.trim(),
        password: txt_password.text.trim(),
      );

      Navigator.pop(context);
      Navigator.pushNamed(context, '/welcome');
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = "user_not_found_error".tr(context); // Traduction des erreurs
      } else if (e.code == 'wrong-password') {
        errorMessage = "wrong_password_error".tr(context); // Traduction des erreurs
      } else {
        errorMessage = "general_error".tr(context); // Traduction des erreurs
      }

      final snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
