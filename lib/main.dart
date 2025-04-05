import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'friends_page.dart';
import 'friend_card.dart';
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
                return HomePage(Details(
                    snapshot.data?.uid ?? "",
                    snapshot.data?.displayName ?? "",
                    snapshot.data?.email ?? "",
                    snapshot.data?.phoneNumber ?? "",
                    snapshot.data?.photoURL ?? ""));
              }
              return const LoginPage();
            }));
  }
}

class Details {
  Details(
      this.uid, this.displayName, this.email, this.phoneNumber, this.photoURL);
  final String uid;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String photoURL;
  String location = "";
}

class HomePage extends StatefulWidget {
  final Details details;

  const HomePage(this.details, {super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Location mLocation = Location();
  StreamSubscription<LocationData>? mLocationSub;

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
        geocoding.Placemark placemark = placemarks.first;
        String loc = "";
        if (placemark.country != null) {
          if (placemark.locality != null && placemark.locality!.isNotEmpty) {
            loc = "${placemark.locality!}, ${placemark.country!}";
          } else if (placemark.subAdministrativeArea != null &&
              placemark.subAdministrativeArea!.isNotEmpty) {
            loc = "${placemark.subAdministrativeArea!}, ${placemark.country!}";
          }
        }
        if (loc != "" && loc != widget.details.location) {
          setState(() {
            widget.details.location = loc;
          });
          uploadDataToDB();
        }
      }
    }
  }

  Future<void> uploadDataToDB() async {
    try {
      FirebaseFirestore.instance.collection("data").doc(widget.details.uid)
        .set({
          "location": widget.details.location,
          "time": FieldValue.serverTimestamp()
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print(e); // Add snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Boing!!!"),
      ),
      drawer: Drawer(
        child: ListView(children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(widget.details.displayName),
            accountEmail: Text(widget.details.location),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.black26, child: Text(":)")
            ),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary)
          ),
          ListTile(
            title: const Text("Friends"),
            trailing: const Icon(Icons.people),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const FriendsPage()
            ))
          ),
          ListTile(
            title: const Text("Details"),
            trailing: const Icon(Icons.list_alt),
            onTap: () {}
          ),
          ListTile(
            title: const Text("Log Out"),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              mLocationSub?.cancel();
              FirebaseAuth.instance.signOut();
            }
          ),
        ])
      ),
      body: Column(children: <Widget>[
        Container(
          color: Theme.of(context).colorScheme.primary,
          width: MediaQuery.of(context).size.width,
          child: const Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: Center(child: Text(
              "Look who is in your area!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ))
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
              .collection("network")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting
                  || !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!["friends"].length,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                      .collection("data")
                      .doc(snapshot.data!["friends"][index])
                      .snapshots(),
                    builder: (context, friendSnapshot) {
                      if (friendSnapshot.connectionState == ConnectionState.waiting
                          || !friendSnapshot.hasData
                          || !friendSnapshot.data!.exists
                          || friendSnapshot.data!["location"] != widget.details.location
                      ) {
                        return Container();
                      }
                      return Container( 
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 2.0),
                          )
                        ),
                        child: FriendCard(
                          name: friendSnapshot.data!["name"],
                          location: friendSnapshot.data!["location"],
                          photo: friendSnapshot.data!["photo"],
                        )
                      );
                    }
                  );
                },
              );
            },
          )
        )
      ]
    ));
  }
}