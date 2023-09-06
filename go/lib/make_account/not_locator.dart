import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Locator extends StatefulWidget {
  @override
  _LocatorState createState() => _LocatorState();
}

class _LocatorState extends State<Locator> {
  Completer<GoogleMapController> _controller = Completer();
  /*
  Set<Marker> _markers = {};
  @override
  void initState() {
    super.initState();
    _addMarker(LatLng(37.502466, 127.048132), '진선여자중학교 운동장'); // 첫 번째 마커
    _addMarker(LatLng(37.495708978, 127.0489197694), '역삼중학교 운동장'); // 두 번째 마커
  }

  void _addMarker(LatLng position, String title) {
    _markers.add(
      Marker(
        markerId: MarkerId(title),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.4963, 126.9569),
          //target: LatLng(latitude, longitude),
          zoom: 14.4746,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        //markers: _markers, // 마커를 지도에 추가
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var gps = await getCurrentLocation();
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(gps.latitude, gps.longitude)),
          );
        },
        child: Icon(
          Icons.my_location,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

Future<Position> getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );
  return position;
}
