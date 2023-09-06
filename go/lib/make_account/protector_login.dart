import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go/protector/location_service.dart';
import 'package:go/protector_page/protector_alarm.dart';
import 'package:go/protector_page/protector_memo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go/protector_page/protector_profile.dart';

class MapSample extends StatefulWidget {
  final String address;
  final String email;
  final FirebaseFirestore firestore;

  const MapSample(
      {required this.address,
      required this.email,
      required this.firestore,
      Key? key})
      : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _addressController = TextEditingController();
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _savedLocations = [];
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.4963, 126.9569),
    zoom: 14.4746,
  );

  double _zoomLevel = 12.0;
  bool followMarker = false; // 실시간으로 마커를 따라가는 상태를 나타내는 변수
  late Timer locationTimer;

  // 현재 선택된 하단바 아이템 인덱스
  int _currentIndex = 0;

  // 하단바 아이템을 눌렀을 때 호출될 함수
  void _onBottomNavigationBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    void _requestLocationPermission() async {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 사용자가 위치 권한을 거부한 경우 처리할 내용 추가
      }
    }

    // 각 인덱스에 따라 다른 페이지로 이동
    if (_currentIndex == 0) {
      // 'Alarm setting' 페이지로 이동하는 코드 작성
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProtectorAlarm(email: widget.email)));
    } else if (_currentIndex == 1) {
      // 'Memo' 페이지로 이동하는 코드 작성
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProtectorMemo(email: widget.email)));
    } else if (_currentIndex == 2) {
      // 'Profile' 페이지로 이동하는 코드 작성
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProtectorProfile(email: widget.email)));
    }
  }

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.address;
    _addMarkerAndCircleForAddress(widget.address);
    FlutterLocalNotification.init(); // Initialize notifications
    startLocationTimer();
    _requestLocationPermission();

  }

  void _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 사용자가 위치 권한을 거부한 경우 처리할 내용 추가
    }
  }

  void startLocationTimer() {
    locationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      print("위치정보 가져옴");
      widget.firestore
          .collection('Login')
          .doc(widget.email) // 사용자의 고유 식별자를 사용하여 문서 가져오기
          .collection('Locations')
          .orderBy('timestamp',
              descending: true) // 'timestamp' 필드를 기준으로 내림차순 정렬
          .limit(1) // 가장 최근 1개의 문서만 가져오도록 제한
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          double latitude = querySnapshot.docs[0]['latitude'];
          double longitude = querySnapshot.docs[0]['longitude'];
          print("위치-> ${latitude} , ${longitude}");

          _currentLocation = LatLng(latitude, longitude);
          _updateMarker();
        }
      });
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
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _buildMarkers(),
              circles: circles,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.alarm), label: 'Alarm setting'),
          BottomNavigationBarItem(
              icon: Icon(Icons.mark_email_read_outlined), label: 'Memo'),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity), label: 'Profile'),
        ],
        currentIndex: _currentIndex, // 현재 선택된 인덱스 설정
        onTap: _onBottomNavigationBarTapped, // 하단바 아이템 눌렀을 때 호출될 함수 설정
      ),
    );
  }

  void _updateMarker() {
    if (_currentLocation != null) {
      setState(() {
        _buildMarkers(); // Update markers with the new data
      });
    }
  }

  void _addMarkerAndCircleForAddress(String address) async {
    var place = await LocationService().getPlace(address);

    if (place != null) {
      _savedLocations.add(place);
      _buildMarkers();
    } else {
      print('주소를 찾을 수 없습니다.');
    }
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    if (_currentLocation != null) {
      final currentLocationMarker = Marker(
        markerId: MarkerId('current_location_marker'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      markers.add(currentLocationMarker);
    }

    for (var place in _savedLocations) {
      final double lat = place['geometry']['location']['lat'];
      final double lng = place['geometry']['location']['lng'];
      final String placeName = place['name'];
      final double distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        lat,
        lng,
      );

      if (distance > 1000) {
        // Assuming the radius is 1000 meters
        print("반경 탈출"); // Print a message if marker is outside the radius
        FlutterLocalNotification.showNotification();
      }

      final circle = Circle(
        circleId: CircleId(placeName),
        center: LatLng(lat, lng),
        radius: 1000, // 반경 1km (미터 단위로 설정)
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2), // 채우는 색상, 여기서는 투명도를 주어 테두리만 표시
      );
      circles.add(circle); // 원을 추가
    }

    return markers;
  }

  Set<Circle> circles = {}; // Circle 위젯을 저장할 변수
}

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    IOSInitializationSettings iosInitializationSettings =
        const IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: IOSNotificationDetails(
          badgeNumber: 1,
        ));

    await flutterLocalNotificationsPlugin.show(
        0, '<보호대상자 위치 변경>', '보호대상자가 반경 밖으로 벗어났습니다', notificationDetails);
  }
}
