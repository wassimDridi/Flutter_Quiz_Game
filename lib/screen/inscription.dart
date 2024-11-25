import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../extensions/extensions.dart'; // Importer l'extension .tr
import 'package:quizzz/parameter/app_localizations.dart';

class InscriptionPage extends StatelessWidget {
  TextEditingController txt_login = TextEditingController();
  TextEditingController txt_password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('signup_page_title'.tr(context)), // Traduction du titre
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
                prefixIcon: Icon(Icons.password),
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
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                _onInscrire(context);
              },
              child: Text(
                'signup_button'.tr(context), // Traduction du bouton
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth');
            },
            child: Text(
              "already_have_account".tr(context), // Traduction du texte
              style: TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onInscrire(BuildContext context) async {
    if (txt_login.text.trim().isNotEmpty &&
        txt_password.text.trim().isNotEmpty) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: txt_login.text.trim(),
          password: txt_password.text.trim(),
        );

        Navigator.pop(context);
        Navigator.pushNamed(context, '/welcome');
      } on FirebaseAuthException catch (e) {
        SnackBar snackBar;

        if (e.code == 'weak-password') {
          snackBar = SnackBar(
            content: Text('weak_password_error'.tr(context)), // Traduction des erreurs
          );
        } else if (e.code == 'email-already-in-use') {
          snackBar = SnackBar(
            content: Text('email_in_use_error'.tr(context)), // Traduction des erreurs
          );
        } else if (e.code == 'invalid-email') {
          snackBar = SnackBar(
            content: Text('invalid_email_error'.tr(context)), // Traduction des erreurs
          );
        } else {
          snackBar = SnackBar(
            content: Text('${"error_prefix".tr(context)} ${e.message}'), // Erreur générique traduite
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      const snackBar = SnackBar(
        content: Text('empty_fields_error'), // Traduction du message
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
