import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    setState(() { busy = true; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
        ).then((uc) => uc.user?.updateDisplayName(nameController.text));
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      setState(() { busy = false; });
    } on FirebaseAuthException catch (e) {
      print(e.message ?? "Failed to create an account");
      setState(() { busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: AuthenticationLayout(
          onMainButtonTapped: createUser,
          onBackPressed: () { Navigator.pop(context); },
          title: 'Create Account',
          subtitle: 'Enter your name, email and password for sign up.',
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
          showTermsText: true,
          busy: busy,
        )
      ),
    );
  }
}