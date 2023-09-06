import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go/make_account/success_signup.dart';

class UserInfoPage4 extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  UserInfoPage4({required this.email});

  @override
  _UserInfoPage4State createState() => _UserInfoPage4State();
}

class _UserInfoPage4State extends State<UserInfoPage4> {
  TextEditingController protectorNameController = TextEditingController();
  TextEditingController protectorAgeController = TextEditingController();
  TextEditingController protectorRelationController = TextEditingController();

  void _handleSaveUserInfo() {
    // 사용자 정보를 Firebase에 저장하는 코드 작성
    FirebaseFirestore.instance.collection("users").doc(widget.email).update({
      "protectorName": protectorNameController.text,
      "protectorAge": protectorAgeController.text,
      "protectorRelation": protectorRelationController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호자 정보 입력")),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: protectorNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "보호자 이름",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: protectorAgeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "보호자 나이",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: protectorRelationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "보호대상자와의 관계",
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
                    builder: (context) => SuccessPage(email: widget.email),
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