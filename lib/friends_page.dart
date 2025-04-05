import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'qr_scanner.dart';
import 'friend_card.dart';
import 'request_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            tooltip: "Add friends",
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const QrScannerPage()
            ))
          ),
          IconButton(
            icon: const Icon(Icons.emoji_people_outlined),
            tooltip: "Friend requests",
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const RequestPage()
            ))
          ),
        ],
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
              itemCount: snapshot.data!["friends"].length,
              itemBuilder: (context, index) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                    .collection("data")
                    .doc(snapshot.data!["friends"][index])
                    .snapshots(),
                  builder: (context, friendSnapshot) {
                    if (friendSnapshot.connectionState == ConnectionState.waiting
                        || !friendSnapshot.hasData
                        || !friendSnapshot.data!.exists
                    ) {
                      return Container();
                    }
                    return Container( 
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 2.0),
                        )
                      ),
                      child: FriendCard(
                        name: friendSnapshot.data!["name"],
                        location: friendSnapshot.data!["location"],
                        photo: friendSnapshot.data!["photo"],
                      )
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