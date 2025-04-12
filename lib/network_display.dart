import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'friend_card.dart';

class FriendDisplay extends StatelessWidget {
  final String networkList;
  final Widget noDataWidget;
  final Widget cardWidget;
  const FriendDisplay({
    super.key,
    required this.networkList,
    required this.noDataWidget,
    required this.cardWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
        .collection(networkList)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data![networkList].isEmpty) {
          return Container();
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
            .collection("data")
            .where(FieldPath.documentId, whereIn: snapshot.data![networkList])
            .snapshots(),
          builder: (context, reqSnapshot) {
            if (reqSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data![networkList].isEmpty) {
              return noDataWidget;
            }
            return Expanded(
              child: ListView.builder(
                itemCount: reqSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Container( 
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 2.0),
                      )
                    ),
                    child: cardWidget(snapshot, reqSnapshot)
                  );
                }
              )
            );
          }
        );
      }
    );
  }
}