import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'network_display.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: NetworkDisplay(
        group: "requests",
        noDataWidget: const Center(child: Text("No new requests")),
        tickBuilder: (snapshot, reqSnapshot, index) =>
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Confirm",
            onPressed: () async {
              FirebaseFirestore.instance
                .collection("network")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
                  "requests": FieldValue.arrayRemove([
                    snapshot.data!["requests"][index]
                  ])},
                  SetOptions(merge: true),
                );
              FirebaseFirestore.instance
                .collection("network")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
                  "friends": FieldValue.arrayUnion([
                    snapshot.data!["requests"][index]
                  ])},
                  SetOptions(merge: true),
                );
              FirebaseFirestore.instance
                .collection("network")
                .doc(snapshot.data!["requests"][index])
                .set({
                  "friends": FieldValue.arrayUnion([
                    FirebaseAuth.instance.currentUser!.uid
                  ])},
                  SetOptions(merge: true),
                );
            }
          ),
        crossBuilder: (snapshot, reqSnapshot, index) =>
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Ignore",
            onPressed: () async {
              FirebaseFirestore.instance
                .collection("network")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
                  "requests": FieldValue.arrayRemove([
                    snapshot.data!["requests"][index]
                  ])
                });
            },
          ),
      )
    );
  }
}