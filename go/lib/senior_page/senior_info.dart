import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeniorInfo extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  SeniorInfo({required this.email});

  @override
  _SeniorInfoState createState() => _SeniorInfoState();
}

class _SeniorInfoState extends State<SeniorInfo> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      DocumentSnapshot userDocSnapshot = await firestore.collection("users").doc(widget.email).get();

      if (userDocSnapshot.exists) {
        setState(() {
          userInfo = userDocSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("내 정보")),
      body: Center(
        child: userInfo != null
            ? SingleChildScrollView(
          padding: EdgeInsets.all(20), // 전체적인 패딩 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: <Widget>[
              Text(
                "[보호대상자 정보]",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // 글씨 크기와 굵기 설정
              ),
              SizedBox(height: 20), // 텍스트 간격 조정
              Text("이름: ${userInfo!['name']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("나이: ${userInfo!['age']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("주소: ${userInfo!['address']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("설정된 반경: ${userInfo!['radius']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("키: ${userInfo!['cm']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("몸무게: ${userInfo!['kg']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("1.비상연락망: ${userInfo!['phone1']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 5),
              Text("(1).관계: ${userInfo!['phone1Relation']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("2.비상연락망: ${userInfo!['phone2']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 5),
              Text("(2).관계: ${userInfo!['phone2Relation']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("3.비상연락망: ${userInfo!['phone3']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 5),
              Text("(3).관계: ${userInfo!['phone3Relation']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 80), // 텍스트 간격 조정
              Text(
                "[보호자 정보]                                             ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // 글씨 크기와 굵기 설정
              ),
              SizedBox(height: 20), // 텍스트 간격 조정
              Text("이름: ${userInfo!['protectorName']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("나이: ${userInfo!['protectorAge']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10), // 텍스트 간격 조정
              Text("보호대상자와의 관계: ${userInfo!['protectorRelation']}", style: TextStyle(fontSize: 18)),
              // 다른 정보도 필요에 따라 추가해주세요
            ],
          ),
        )
            : CircularProgressIndicator(), // 정보 로딩 중에는 로딩 표시를 보여줍니다
      ),
    );
  }
}
