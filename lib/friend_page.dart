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
          String? photo = data["photo"];
          return Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: (photo != null && photo.isNotEmpty)
                      ? Image.network(
                        photo,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator()
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Image(
                            image: AssetImage('assets/default_icon.png'),
                            fit: BoxFit.cover
                          );
                        },
                      )
                      : const Image(
                        image: AssetImage('assets/default_icon.png'),
                        fit: BoxFit.cover,
                      ),
                  ),
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
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                Center(child: Text(data["status"] ?? "--")),
                const SizedBox(height: 10),
                const Divider(),
                Expanded(child: Container()),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Message",
                      style: TextStyle(color: Colors.white)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Poke",
                      style: TextStyle(color: Colors.white)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => deleteFriendConfirm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      elevation: 0,
                      side: BorderSide.none,
                      shape: const StadiumBorder()
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red)
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }
      )
    );
  }

  void deleteFriendConfirm(BuildContext context) {
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
  }
}