import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지 추가
import 'package:get/get.dart';
import 'package:go/senior_page/senior_game.dart';
import 'package:go/senior_page/senior_health.dart';
import 'package:go/senior_page/senior_info.dart';
import 'package:go/senior_page/senior_memo.dart';
import 'package:geolocator/geolocator.dart';

class SeniorLogin extends StatefulWidget {
  @override
  final String email;

  SeniorLogin({required this.email});
  _SeniorLoginState createState() => _SeniorLoginState();
}

class _SeniorLoginState extends State<SeniorLogin> {
  String locationText = "";
  late Timer locationTimer;
  late FirebaseFirestore firestore; // Firestore 인스턴스

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance; // Firestore 인스턴스 초기화
    startLocationTimer();


  }

  void startLocationTimer() {
    locationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentLocation();
      print("위치 함수 호츌");
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Firestore에 위치 정보 저장
      await FirebaseFirestore.instance
          .collection("Login")
          .doc(widget.email) // 사용자 고유 UID를 문서 ID로 사용
          .collection("Locations") // 사용자마다 개별 컬렉션 생성
          .add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        locationText = "현재 위치: ${position.latitude}, ${position.longitude}";
      });

      print("저장 성공"); // 저장 성공 시 출력
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        locationText = "위치 정보를 가져오는 데 실패했습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호대상자")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(SeniorHealth(email: widget.email));
              },
              child: Container(
                width: 300,
                height: 130,
                alignment: Alignment.center,
                child: Text("[약 먹는 시간 알림]", style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(SeniorGame());
              },
              child: Container(
                width: 300,
                height: 130,
                alignment: Alignment.center,
                child: Text("[치매예방 사진기억도우미]", style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(SeniorMemo(email: widget.email));
              },
              child: Container(
                width: 300,
                height: 130,
                alignment: Alignment.center,
                child: Text("[메모지]", style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(SeniorInfo(email: widget.email));
              },
              child: Container(
                width: 300,
                height: 130,
                alignment: Alignment.center,
                child: Text("[내정보]", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    locationTimer.cancel();
    super.dispose();
  }
}