import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Profile"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection("data")
          .doc(currentUser.uid)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting
              || !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data!.data()!;
          return Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(image: AssetImage('assets/default_icon.png'))
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration:
                        BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Theme.of(context).colorScheme.inversePrimary
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 20
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 50),
                    Text(
                      data["name"] ?? "-",
                      style: Theme.of(context).textTheme.headlineMedium
                    ),
                    Stack(
                      children: [
                        const SizedBox(width: 50),
                        IconButton(
                          onPressed: () => changeName(context, data["name"] ?? ""),
                          icon: const Icon(Icons.edit, color: Colors.black45),
                        ),
                      ],
                    )
                  ],
                ),
                Text(
                  "Last online: ${
                    data["time"] == null ? "--"
                      : DateFormat('MM/dd/yyyy, hh:mm a').format(data["time"].toDate())
                  }",
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                UserInfoField(
                  label: "Location:",
                  info: data["location"] ?? ""
                ),
                UserInfoField(
                  label: "Email:",
                  info: currentUser.email ?? ""
                ),
                UserInfoField(
                  label: "Status:",
                  info: data["status"] ?? "",
                  editCallback: () => changeStatus(context, data["status"] ?? ""),
                ),
                const SizedBox(height: 10),
                if (currentUser.providerData .map((e) => e.providerId)
                    .contains("password"))
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => const ChangePasswordPage()
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white)
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => deleteAccountConfirm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red)
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      )
    );
  }

  void deleteAccountConfirm(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Deleting an account is permanent.'),
            const Text('Type in email to confirm.'),
            TextField(controller: controller),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text != currentUser.email) {
                return;
              }
              FirebaseFirestore.instance.collection("data").doc(currentUser.uid).delete();
              FirebaseFirestore.instance.collection("network").doc(currentUser.uid).delete();
              currentUser.delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Account deleted"),
              ));
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Confirm'),
          ),
        ],
      )
    );
  }

  void changeName(BuildContext context, String name) {
    controller.text = name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name'),
        content: TextField(
          controller: controller,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              FirebaseAuth.instance.currentUser!
                .updateDisplayName(controller.text.trim());
              FirebaseFirestore.instance.collection("data")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set(
                  {"name": controller.text.trim()},
                  SetOptions(merge: true),
                );
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      )
    );
  }

  void changeStatus(BuildContext context, String status) {
    controller.text = status;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status'),
        content: TextField(
          controller: controller,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              FirebaseFirestore.instance.collection("data")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set(
                  {"status": controller.text},
                  SetOptions(merge: true),
                );
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      )
    );
  }
}

class UserInfoField extends StatelessWidget {
  const UserInfoField({
    super.key,
    required this.label,
    required this.info,
    this.editCallback
  });

  final String label;
  final String info;
  final void Function()? editCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0 / 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Expanded(
            flex: 4,
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: info,
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0 * 1.5, vertical: 16.0
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                suffixIcon: editCallback == null ? null : IconButton(
                  onPressed: editCallback!,
                  icon: const Icon(Icons.edit, color: Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}