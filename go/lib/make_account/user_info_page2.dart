import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go/make_account/user_info_page3.dart';

class UserInfoPage2 extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  UserInfoPage2({required this.email});

  @override
  _UserInfoPage2State createState() => _UserInfoPage2State();
}

class _UserInfoPage2State extends State<UserInfoPage2> {
  TextEditingController addressController = TextEditingController();
  TextEditingController radiusController = TextEditingController();

  void _handleSaveUserInfo() {
    // 사용자 정보를 Firebase에 저장하는 코드 작성
    FirebaseFirestore.instance.collection("users").doc(widget.email).update({
      "address": addressController.text,
      "radius": radiusController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호대상자 주소 입력")),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "address",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: radiusController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "radius",
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 사용자 정보를 Firebase에 저장
                _handleSaveUserInfo();
                // 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage3(email: widget.email),
                  ),
                );
              },
              child: Text("완료"),
            ),
          ],
        ),
      ),
    );
  }
}
