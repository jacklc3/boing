import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'authentication_layout.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool busy = false;
  String? validationMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUser(BuildContext context) async {
    setState(() { busy = true; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
        ).then((uc) => uc.user?.updateDisplayName(nameController.text.trim()));
      String qrid = Uuid().v4();
      await FirebaseFirestore.instance.collection("network")
        .doc(FirebaseAuth.instance.currentUser!.uid).set({
          "requests": [],
          "friends": [],
          },
          SetOptions(merge: true),
        );
      await FirebaseFirestore.instance.collection("data")
        .doc(FirebaseAuth.instance.currentUser!.uid).set({
          "name": nameController.text.trim(),
          "time": FieldValue.serverTimestamp(),
          "qrid": qrid,
          },
          SetOptions(merge: true),
        );
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      setState(() { busy = false; });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Account created"),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        validationMessage = e.message ?? "Failed to create an account";
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: AuthenticationLayout(
          onMainButtonTapped: () => createUser(context),
          onBackPressed: () { Navigator.pop(context); },
          title: 'Create Account',
          subtitle: 'Enter your name, email and password to sign up.',
          mainButtonTitle: 'SIGN UP',
          form: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: nameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: emailController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                controller: passwordController,
                obscureText: true,
              ),
            ],
          ),
          validationMessage: validationMessage,
          showTermsText: true,
          busy: busy,
        )
      ),
    );
  }
}