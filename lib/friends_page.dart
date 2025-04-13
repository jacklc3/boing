import 'package:boing/network_display.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'qr_scanner_page.dart';
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
      body: const NetworkDisplay(
          group: "friends",
          noDataWidget: Center(child: Text("Time to make some friends!"))
        )
    );
  }
}