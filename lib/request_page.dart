import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'friend_card.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
            .collection("network")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting
                || !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!["requests"].length,
              itemBuilder: (context, index) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                    .collection("data")
                    .doc(snapshot.data!["requests"][index])
                    .snapshots(),
                  builder: (context, requestSnapshot) {
                    if (requestSnapshot.connectionState == ConnectionState.waiting
                        || !requestSnapshot.hasData
                        || !requestSnapshot.data!.exists
                    ) {
                      return Container();
                    }
                    return Container( 
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 2.0),
                        )
                      ),
                      child: Row(children: [
                        Expanded(child: FriendCard(
                          name: requestSnapshot.data!["name"],
                          location: requestSnapshot.data!["location"],
                          photo: requestSnapshot.data!["photo"],
                        )),
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
                      ])
                    );
                  }
                );
              },
            );
          },
        )
      )
    );
  }
}