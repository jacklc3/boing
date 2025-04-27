import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'constants.dart';

class FriendPage extends StatelessWidget {
  final String uid;

  const FriendPage({
    required this.uid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Profile"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection("data")
          .doc(uid)
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
                  if (data["status"] != null)
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          const Expanded(child: Divider()),       
                          Text(
                            ' STATUS ',
                            style: bodyStyle.copyWith(color: kcMediumGreyColor),
                            textAlign: TextAlign.start
                          ),
                          const Expanded(child: Divider()),
                        ]
                      )
                    ),
                  if (data["status"] != null)
                    const SizedBox(height: 20),
                  if (data["status"] != null)
                    UserInfoField(label: "Status:", info: data["status"] ?? ""),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text('Deleting friends cannot be undone'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  FirebaseFirestore.instance
                                    .collection("network")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .set({
                                      "friends": FieldValue.arrayRemove([uid])},
                                      SetOptions(merge: true),
                                    );
                                  FirebaseFirestore.instance
                                    .collection("network")
                                    .doc(uid)
                                    .set({
                                      "friends": FieldValue.arrayRemove([
                                        FirebaseAuth.instance.currentUser!.uid
                                      ])},
                                      SetOptions(merge: true),
                                    );
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          )
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        side: BorderSide.none,
                        shape: const StadiumBorder()
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white)
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