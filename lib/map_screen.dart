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
      });
       _getLocationData();
      });

    super.initState();
  }

  Future _getLocationData() async{
    await http.post(
        'https://outpost.mapmyindia.com/api/security/oauth/token',
        body:{
          'grant_type':'client_credentials',
          'client_id':'xc8MS6f5NXZa9U0W3wAXkMYfmkXeIYrG7p23ECbDVU26GncAiTYZL3FNkLfnqlZdnvyrWdUjHvL38UrNvCmNx_VP6r2xbyn6',
          'client_secret':'kBW6kL4FZru7TuVmUq-Dwk3hSjI6dUUzZ3ZiB3KVpt4Jv0P8wWd4-NygyLW_O2oT0gHXlB8VaJ885V206mrtvWoErEsfhHlB3Ruu0aZl3Dc=',
        },
        headers:{
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        encoding: Encoding.getByName('utf-8')
    ).then((response){
      print(json.decode(response.body)['access_token']);
      http.get(
        //'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=23.1060952,72.5880265&radius=1500&keyword=chair&key=AIzaSyAic3e4Kt0mfxq6p3z-q8etA7XvvnSFGLU'.
        'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=coffee;beer&refLocation=${_currentLocation.latitude},${_currentLocation.longitude}',
        headers:{
          'Authorization':'${json.decode(response.body)['token_type']} ${json.decode(response.body)['access_token']}'
        },
      ).then((response){
        print(json.decode(response.body));
        setState(() {
          _isLoading=false;
        });
      } );
    } );
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
              myLocationEnabled: true,
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
