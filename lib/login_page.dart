import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authentication_layout.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: AuthenticationLayout(
          onMainButtonTapped: useEmailPasswordAuthentication,
          onCreateAccountTapped: () { Navigator.push(context, SignUpPage.route()); },
          title: 'Welcome to Boing!',
          subtitle: 'Enter your email address to sign in.',
          mainButtonTitle: 'SIGN IN',
          form: Column(
            children: [
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
          onForgotPassword: () {},
          onSignInWithGoogle: useGoogleAuthentication,
          // onSignInWithApple: useAppleAuthentication,
          busy: busy,
        )
      )
    );
  }

  Future<void> useEmailPasswordAuthentication() async {
    setState(() { busy = true; });
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() { busy = false; });
    }
  }

  Future<void> useGoogleAuthentication() async {
    setState(() { busy = true; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print(userCredential);
    } on Exception catch (e) {
      print(e);
      setState(() { busy = false; });
    }
  }
}