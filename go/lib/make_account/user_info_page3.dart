import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go/make_account/user_info_page4.dart';

class UserInfoPage3 extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  UserInfoPage3({required this.email});

  @override
  _UserInfoPage3State createState() => _UserInfoPage3State();
}

class _UserInfoPage3State extends State<UserInfoPage3> {
  TextEditingController phone1Controller = TextEditingController();
  TextEditingController phone2Controller = TextEditingController();
  TextEditingController phone3Controller = TextEditingController();
  TextEditingController phone1RelationController = TextEditingController();
  TextEditingController phone2RelationController = TextEditingController();
  TextEditingController phone3RelationController = TextEditingController();

  void _handleSaveUserInfo2() {
    // 사용자 정보를 Firebase에 저장하는 코드 작성
    FirebaseFirestore.instance.collection("users").doc(widget.email).update({
      "phone1": phone1Controller.text,
      "phone1Relation": phone1RelationController.text,
      "phone2": phone2Controller.text,
      "phone2Relation": phone2RelationController.text,
      "phone3": phone3Controller.text,
      "phone3Relation": phone3RelationController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호대상자 비상연락망 입력")),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: phone1Controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "1. 비상연락망",
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: phone1RelationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "1. 보호대상자와의 관계",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: phone2Controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "2. 비상연락망",
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: phone2RelationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "2. 보호대상자와의 관계",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: phone3Controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "3. 비상연락망",
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: phone3RelationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "3. 보호대상자와의 관계",
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 사용자 정보를 Firebase에 저장
                _handleSaveUserInfo2();
                // 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage4(email: widget.email),
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