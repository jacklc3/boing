import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
    List<(String, String)> mDetails = [
        ("Name", "John Doe"),
        ("Location", ""),
        ("Email", "john.doe@gmail.com"),
        ("LinkedIn", "@john.doe"),
    ];
    late StreamSubscription<Position> mPositionStream;

    void setMainState() {
        setState((){});
    }

    @override
    void initState() {
        super.initState();
        initPositionStream();
    }

    void initPositionStream() async {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
            print('Location services are disabled.');
            return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
            print( 'Location permissions are permanently denied, we cannot request permissions.');
            return;
        }
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
                print('Location permissions are denied');
                return;
            }
        }

        final locationSettings = LocationSettings(accuracy: LocationAccuracy.low, distanceFilter: 5000);
        mPositionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) { getLocationFromPosition(position); });
    }

    Future<void> getLocationFromPosition(Position? position) async {
        print(position);
        if (position != null) {
            List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
            if (placemarks != null && placemarks.isNotEmpty) {
                Placemark placemark = placemarks.first;
                print(placemark);
                String loc = '${placemark.locality}, ${placemark.country}';
                setState((){ mDetails[1] = (mDetails[1].$1, loc); });
            }
        }
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
                            accountName: new Text(mDetails[0].$2),
                            accountEmail: new Text(mDetails[1].$2),
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
                                    builder: (BuildContext context) => new DetailsPage(mDetails, setMainState)
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
