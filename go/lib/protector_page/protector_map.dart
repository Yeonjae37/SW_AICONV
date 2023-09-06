/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MapSample(address: 'Initial Address', firestore: FirebaseFirestore.instance)));
}

class MapSample extends StatefulWidget {
  final String address;
  final FirebaseFirestore firestore;

  const MapSample({required this.address, required this.firestore, Key? key})
      : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _addressController = TextEditingController();
  LatLng? _currentLocation;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.3943, 126.9568), // 안양역의 위도와 경도로 변경
    zoom: 14.0,
  );

  double _zoomLevel = 12.0;
  bool followMarker = false; // 실시간으로 마커를 따라가는 상태를 나타내는 변수
  late Timer locationTimer;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.address;
    _addMarkerAndCircleForAddress(widget.address);
    _getCurrentLocation();
    startLocationTimer();
  }

  void startLocationTimer() {
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    locationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보호대상자의 위치'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: 'Search by City'),
                  onChanged: (value) {
                    _addMarkerAndCircleForAddress(value);
                  },
                ),
              ),
              IconButton(
                onPressed: () async {
                  var place = await getLocationFromAddress(_addressController.text);
                  _saveAndGoToPlace(place);
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                followMarker = !followMarker; // 버튼을 누를 때마다 실시간 따라가기 상태 변경
                if (followMarker && _currentLocation != null) {
                  _goToPlace(_currentLocation!); // 따라가기 상태가 활성화되면 현재 위치로 화면 이동
                }
              });
            },
            child: Text(followMarker ? '따라가기 중지' : '마커 실시간 따라가기'),
          ),
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                setState(() {
                  _zoomLevel = _kGooglePlex.zoom * details.scale;
                });
              },
              child: GoogleMap(
                mapType: MapType.normal,
                markers: _buildMarkers(),
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _addMarkerAndCircleForAddress(String address) async {
    var place = await getLocationFromAddress(address);

    if (place != null) {
      _goToPlace(LatLng(place['latitude'], place['longitude']));
    } else {
      print('주소를 찾을 수 없습니다.');
    }
  }

  void _saveAndGoToPlace(Map<String, dynamic>? place) {
    if (place != null) {
      setState(() {
        _currentLocation = LatLng(place['latitude'], place['longitude']);
      });
      _goToPlace(LatLng(place['latitude'], place['longitude']));
    }
  }

  Future<void> _goToPlace(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: _zoomLevel),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    if (_currentLocation != null) {
      final marker = Marker(
        markerId: MarkerId('current_location_marker'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      );

      markers.add(marker);
    }

    return markers;
  }
}

Future<Map<String, dynamic>?> getLocationFromAddress(String address) async {
// Implement your code to get location from address, return a Map<String, dynamic> containing location data.
  return null; // Replace with actual implementation
}

 */