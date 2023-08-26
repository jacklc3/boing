import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(title: new Text("Friends")),
            body: new Center(child: new Text("You have none :("))
        );
    }
}
