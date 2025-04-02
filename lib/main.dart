import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'details.dart';
import 'friends.dart';
import 'firebase_options.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Boing',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.idTokenChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data != null) {
                return HomePage(snapshot.data!);
              }
              return const LoginPage();
            }));
  }
}

class HomePage extends StatefulWidget {
  final User mUser;

  const HomePage(this.mUser, {super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState() {
    mDetails = [
      (
        "Name",
        FirebaseAuth.instance.currentUser?.displayName == null
            ? ""
            : FirebaseAuth.instance.currentUser!.displayName!
      ),
      ("Location", ""),
      (
        "Email",
        FirebaseAuth.instance.currentUser?.email == null
            ? ""
            : FirebaseAuth.instance.currentUser!.email!
      ),
    ];
  }

  late List<(String, String)> mDetails;
  final Location mLocation = Location();
  StreamSubscription<LocationData>? mLocationSub;

  void setMainState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  void initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await mLocation.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await mLocation.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await mLocation.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await mLocation.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    mLocationSub = mLocation.onLocationChanged.listen((LocationData location) {
      getLocation(location);
    });
  }

  Future<void> getLocation(LocationData location) async {
    if (location.latitude != null && location.longitude != null) {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(location.latitude!, location.longitude!);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark p = placemarks.first;
        String loc = "";
        if (p.country != null) {
          if (p.locality != null && p.locality!.isNotEmpty) {
            loc = "${p.locality!}, ${p.country!}";
          } else if (p.subAdministrativeArea != null &&
              p.subAdministrativeArea!.isNotEmpty) {
            loc = "${p.subAdministrativeArea!}, ${p.country!}";
          }
        }
        setState(() {
          mDetails[1] = (mDetails[1].$1, loc);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Boing!!!"),
      ),
      body: const Center(
        child: Text("Time to go boing!!"),
      ),
      drawer: Drawer(
          child: ListView(children: <Widget>[
        UserAccountsDrawerHeader(
            accountName: Text(mDetails[0].$2),
            accountEmail: Text(mDetails[1].$2),
            currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.black26, child: Text(":)")),
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary)),
        ListTile(
            title: const Text("Friends"),
            trailing: const Icon(Icons.people),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const FriendsPage()))),
        ListTile(
            title: const Text("Details"),
            trailing: const Icon(Icons.list_alt),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    DetailsPage(mDetails, setMainState)))),
        ListTile(
            title: const Text("Log Out"),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              mLocationSub?.cancel();
              FirebaseAuth.instance.signOut();
            }),
      ])),
      //floatingActionButton: FloatingActionButton(),
    );
  }
}
