import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final newPasswordController1 = TextEditingController();
  final newPasswordController2 = TextEditingController();

  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Change Password"),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 20),
            PasswordField(
              label: "New Password:",
              controller: newPasswordController1,
            ),
            PasswordField(
              label: "Confirm Password:",
              controller: newPasswordController2,
            ),
            const SizedBox(height: 10),
            Text(errorMsg, style: const TextStyle(color: Colors.red)),
            Expanded(child: Container()),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: () => changePassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  elevation: 0,
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changePassword(BuildContext context) async {
    if (newPasswordController1.text != newPasswordController2.text) {
      errorMsg = "Passwords do not match";
      return;
    }
    FirebaseAuth.instance.currentUser!.updatePassword(newPasswordController1.text);
    Navigator.pop(context);
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  State<PasswordField> createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0 / 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(widget.label),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              obscureText: hidden,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0 * 1.5, vertical: 16.0
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() { hidden = !hidden; }),
                  icon: const Icon(Icons.remove_red_eye, color: Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}