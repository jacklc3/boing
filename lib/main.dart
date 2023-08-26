import 'package:flutter/material.dart';

import 'details.dart';
import 'friends.dart';

void main() {
  runApp(new Application());
}

class Application extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Boing',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
            ),
            home: new HomePage()
        );
    }
}

class HomePage extends StatefulWidget {
    @override
    State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
    List<(String, String)> details = [
        ("Name", "John Doe"),
        ("Email", "john.doe@gmail.com"),
        ("LinkedIn", "@john.doe"),
    ];

    void setMainState() {
        setState((){});
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text("Boing!!!"),
            ),
            body: Center(
                child: const Text("Time to go boing!!"),
            ),
            drawer: new Drawer(
                child: ListView(
                    children: <Widget>[
                        new UserAccountsDrawerHeader(
                            accountName: new Text(details[0].$2),
                            accountEmail: new Text(details[1].$2),
                            currentAccountPicture: new CircleAvatar(
                                backgroundColor: Colors.black26,
                                child: new Text(":)")
                            ),
                            decoration: new BoxDecoration(color: Theme.of(context).colorScheme.primary)
                        ),
                        new ListTile(
                            title: new Text("Friends"),
                            trailing: new Icon(Icons.people),
                            onTap: () => Navigator.of(context).push(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) => new FriendsPage()
                                )
                            )
                        ),
                        new ListTile(
                            title: new Text("Details"),
                            trailing: new Icon(Icons.list_alt),
                            onTap: () => Navigator.of(context).push(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) => new DetailsPage(details, setMainState)
                                )
                            )
                        ),
                    ]
                )
            ),
            //floatingActionButton: FloatingActionButton(),
        );
    }
}
