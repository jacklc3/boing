import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'friends_page.dart';
import 'network_display.dart';
import 'details.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Location mLocation = Location();
  StreamSubscription<LocationData>? mLocationSub;
  String location = "";

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

    mLocationSub = mLocation.onLocationChanged.listen(getLocation);
  }

  Future<void> getLocation(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(locationData.latitude!, locationData.longitude!);
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
        if (loc != "" && loc != location) {
          setState(() {
            location = loc;
          });
          uploadDataToDB();
        }
      }
    }
  }

  Future<void> uploadDataToDB() async {
    try {
      FirebaseFirestore.instance.collection("data")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          "location": location,
          "time": FieldValue.serverTimestamp()
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      log(e.toString()); // Add snackbar
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
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection("data")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
            builder: (context, snapshot) {
              String name = "";
              if (snapshot.connectionState != ConnectionState.waiting
                  && snapshot.hasData) {
                if (snapshot.data!.data()?.containsKey("name") ?? false) {
                  name = snapshot.data!["name"];
                }
              }
              return UserAccountsDrawerHeader(
                accountName: Text(name),
                accountEmail: Text(location),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: Text(":)"),
                ),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary)
              );
            }
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
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const DetailsPage()
            ))
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
          child: NetworkDisplay(
            group: "friends",
            noDataWidget: const Center(child: Text("Time to make some friends")),
            queryUpdate: (query) =>
              query.where("location", isEqualTo: location),
          )
        ),
      ])
    );
  }
}