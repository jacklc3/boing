import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  static const fields = <String>["name", "home", "status"];
  String ftext = "";

  void dialog(field) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(field),
        content: TextField(
          onChanged: (String s) { ftext = s; }
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              FirebaseFirestore.instance
                .collection("data")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({field: ftext.trim()});
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () { Navigator.pop(context); },
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Details")
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("data")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return Container();
          }
          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, i) => ListTile(
                title: Text(fields[i]),
                subtitle: Text(snapshot.data!.data()?.containsKey(fields[i]) ?? false
                  ? snapshot.data![fields[i]] : ""),
                onTap: (){ dialog(fields[i]); }
              ),
          );
        }
      )
    );
  }
}