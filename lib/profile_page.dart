import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'update_profile_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser!;
    return Scaffold(
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
          return SingleChildScrollView(
            child: Container(
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data["name"] ?? "",
                    style: Theme.of(context).textTheme.headlineMedium),
                  Text(
                    "Last online: ${
                      data["time"] == null ? "--"
                        : DateFormat('MM/dd/yyyy, hh:mm a').format(data["time"].toDate())
                    }",
                    style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  if (currentUser.email != null)
                    UserInfoField(label: "Email:", info: currentUser.email!),
                  if (currentUser.phoneNumber != null)
                    UserInfoField(label: "Phone:", info: currentUser.phoneNumber!),
                  if (data["location"] != null)
                    UserInfoField(label: "Location:", info: data["location"]),
                  UserInfoField(label: "Status:", info: data["status"] ?? ""),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => const UpdateProfilePage()
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide.none,
                        shape: const StadiumBorder()
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.black)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      )
    );
  }
}

class UserInfoField extends StatelessWidget {
  const UserInfoField({
    super.key,
    required this.label,
    required this.info,
  });

  final String label;
  final String info;

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
            flex: 3,
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: info,
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0 * 1.5, vertical: 16.0
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}