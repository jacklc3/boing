import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

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
    final Location mLocation = Location();

    void setMainState() {
        setState((){});
    }

    @override
    void initState() {
        super.initState();
        initLocation();
    }

    void initLocation() async {
        bool _serviceEnabled;
        PermissionStatus _permissionGranted;

        _serviceEnabled = await mLocation.serviceEnabled();
        if (!_serviceEnabled) {
            _serviceEnabled = await mLocation.requestService();
            if (!_serviceEnabled) {
                return;
            }
        }

        _permissionGranted = await mLocation.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
            _permissionGranted = await mLocation.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
                return;
            }
        }

        mLocation.onLocationChanged.listen((LocationData location) {
            print(location);
            getLocation(location);
        });
    }

    Future<void> getLocation(LocationData location) async {
        if (location.latitude != null && location.longitude != null) {
            List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
                location.latitude!, location.longitude!);
            if (placemarks != null && placemarks.isNotEmpty) {
                geocoding.Placemark p = placemarks.first;
                String loc = "";
                if (p.locality != null && !p.locality!.isEmpty)
                    loc += p.locality! + ", ";
                else if (p.subAdministrativeArea != null && !p.subAdministrativeArea!.isEmpty)
                    loc += p.subAdministrativeArea! + ", ";
                if (p.country != null)
                    loc += p.country!;
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
