import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'friend_card.dart';

Query<Map<String, dynamic>> idUpdate(Query<Map<String, dynamic>> query) {
  return query;
}

class NetworkDisplay extends StatelessWidget {
  final String group;
  final Widget noDataWidget;
  final Widget Function(AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>, int)? tickBuilder;
  final Widget Function(AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>, int)? crossBuilder;
  final Function? tapCallback;
  final Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>) queryUpdate;

  const NetworkDisplay({
    super.key,
    required this.group,
    required this.noDataWidget,
    this.tickBuilder,
    this.crossBuilder,
    this.tapCallback,
    this.queryUpdate = idUpdate,
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
          stream: queryUpdate(FirebaseFirestore.instance
            .collection("data")
            .where(FieldPath.documentId, whereIn: snapshot.data![group]))
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
                      : tickBuilder!(snapshot, index),
                    crossBuilder == null ? Container()
                      : crossBuilder!(snapshot, index),
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