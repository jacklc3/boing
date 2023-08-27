import 'dart:async'

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
    @override
    LocationState createState() => LocationState();
}

class _MyLocationState extends State<MyLocation> {
    Location mCurrentPosition;

    @override
    void initState() {
        super.initState();
        getCurrentLocation();
    }

    _getCurrentLocation() async {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
        addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        setState(() { _currentPosition = position; });
    }
}
