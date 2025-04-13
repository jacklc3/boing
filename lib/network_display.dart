import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'friend_card.dart';

class NetworkDisplay extends StatelessWidget {
  final String group;
  final Widget noDataWidget;
  final Function? tickBuilder;
  final Function? crossBuilder;
  final Function? tapCallback;

  const NetworkDisplay({
    super.key,
    required this.group,
    required this.noDataWidget,
    this.tickBuilder,
    this.crossBuilder,
    this.tapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
        .collection("network")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data![group].isEmpty) {
          return noDataWidget;
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
            .collection("data")
            .where(FieldPath.documentId, whereIn: snapshot.data![group])
            .snapshots(),
          builder: (context, reqSnapshot) {
            if (reqSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!reqSnapshot.hasData || reqSnapshot.data!.docs.isEmpty) {
              return noDataWidget;
            }
            return ListView.builder(
              itemCount: reqSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Container( 
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 2.0),
                    )
                  ),
                  child: Row(children: <Widget>[
                    Expanded(child: FriendCard(
                      name: reqSnapshot.data!.docs[index].data()["name"],
                      home: reqSnapshot.data!.docs[index].data()["home"],
                      photo: reqSnapshot.data!.docs[index].data()["photo"],
                    )),
                    tickBuilder == null ? Container()
                      : tickBuilder!(snapshot, reqSnapshot, index),
                    crossBuilder == null ? Container()
                      : crossBuilder!(snapshot, reqSnapshot, index),
                  ])
                );
              }
            );
          }
        );
      }
    );
  }
}