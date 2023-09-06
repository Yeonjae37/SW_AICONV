import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go/make_account/protector_login.dart';
import 'package:go/make_account/user_info_page2.dart';
import 'package:get/get.dart';

class UserInfoPage extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  UserInfoPage({required this.email});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController diseaseController = TextEditingController();
  TextEditingController cmController = TextEditingController();
  TextEditingController kgController = TextEditingController();

  void _handleSaveUserInfo() {
    // 여기서 사용자 정보를 Firebase에 저장하는 코드를 작성합니다.
    FirebaseFirestore.instance.collection("users").doc(widget.email).set({
      "name": nameController.text,
      "age": ageController.text,
      "disease": diseaseController.text,
      "cm": cmController.text,
      "kg": kgController.text,
    //   // 추가적인 정보들도 필요하다면 여기에 추가합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호대상자 정보 입력")),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Name",
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Age",
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: diseaseController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "disease",
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: cmController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "cm",
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: kgController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "kg",
              ),
            ),
            SizedBox(height: 10.0),

            ElevatedButton(
              onPressed: () {
                // 사용자 정보를 Firebase에 저장합니다 (필요하다면 이 부분을 유지하세요).
                _handleSaveUserInfo();
                Get.to(UserInfoPage2(email: widget.email));
              },
              child: Text("완료"),
            ),
          ],
        ),
      ),
    );
  }
}
