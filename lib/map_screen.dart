import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends  StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var _currentLocation;
  bool _isLoading;
  LatLng _lastMapPosition;
  Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _isLoading=true;
    });
    Geolocator().getCurrentPosition().then((currloc) {
      setState(() {
        _currentLocation = currloc;
        print(_currentLocation);
        _isLoading=false;
      });
      http.get(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=23.1060952,72.5880265&radius=1500&keyword=chair&key=AIzaSyAic3e4Kt0mfxq6p3z-q8etA7XvvnSFGLU'
      ).then((response) => print(json.decode(response.body)));
    });
    super.initState();
  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          (_isLoading)?Center(child:CircularProgressIndicator()):Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              rotateGesturesEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _currentLocation.latitude, _currentLocation.longitude),
                zoom: 15.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
