import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'qr_scanner.dart';
import 'task_card.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            tooltip: "Add friends",
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const QrScannerPage()
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
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                    .collection("data")
                    .doc(snapshot.data!["friends"][index])
                    .get(),
                  builder: (context, friendSnapshot) {
                    if (friendSnapshot.connectionState == ConnectionState.waiting
                        || !friendSnapshot.hasData
                        || !friendSnapshot.data!.exists
                    ) {
                      return Container();
                    }
                    return Row(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            image:
                              DecorationImage(
                                image: NetworkImage(
                                  friendSnapshot.data!["photo"] == ""
                                    ? "https://www.clipartmax.com/png/middle/214-2143742_individuals-whatsapp-profile-picture-icon.png"
                                    : friendSnapshot.data!["photo"]
                                ),
                              ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: TaskCard(
                            headerText:
                              friendSnapshot.data!["name"],
                            descriptionText:
                              friendSnapshot.data!["location"],
                          ),
                        ),
                      ],
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