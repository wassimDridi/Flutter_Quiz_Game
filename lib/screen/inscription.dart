import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../extensions/extensions.dart'; // Importer l'extension .tr

class InscriptionPage extends StatelessWidget {
  final TextEditingController txt_login = TextEditingController();
  final TextEditingController txt_password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('signup_page_title'.tr(context)), // Traduction du titre
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Image.asset(
                'assets/inscription.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                'create_account'.tr(context), // Texte de bienvenue
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'signup_instruction'.tr(context), // Texte d'instruction
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: txt_login,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                  hintText: "user_hint".tr(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.blueAccent[50],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: txt_password,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                  hintText: "password_hint".tr(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.blueAccent[50],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _onInscrire(context),
                child: Text(
                  'signup_button'.tr(context),
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/auth');
                },
                child: Text(
                  "already_have_account".tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            backgroundColor: Colors.red,
          );
        } else if (e.code == 'email-already-in-use') {
          snackBar = SnackBar(
            content: Text('email_in_use_error'.tr(context)), // Traduction des erreurs
            backgroundColor: Colors.red,
          );
        } else if (e.code == 'invalid-email') {
          snackBar = SnackBar(
            content: Text('invalid_email_error'.tr(context)), // Traduction des erreurs
            backgroundColor: Colors.red,
          );
        } else {
          snackBar = SnackBar(
            content: Text('${"error_prefix".tr(context)} ${e.message}'), // Erreur générique traduite
            backgroundColor: Colors.red,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackBar = SnackBar(
        content: Text('empty_fields_error'.tr(context)), // Traduction du message
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
