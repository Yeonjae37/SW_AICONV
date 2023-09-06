import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:go/make_account/signuppage.dart';
import 'package:go/make_account/protector_login.dart';
import 'package:go/make_account/senior_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String email;

  LoginPage({required this.email});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  String id = "";
  String pw = "";
  String userAddress = "";
  bool saveLoginInfo = false; // 추가: 로그인 정보 저장 여부

  @override
  void initState() {
    super.initState();
    _loadSavedLoginInfo();
  }

  void _loadSavedLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('savedId') ?? '';
      pw = prefs.getString('savedPw') ?? '';
      idController.text = id;
      pwController.text = pw;

      if (id.isNotEmpty && pw.isNotEmpty) {
        _handleLogin();
      }
    });
  }

  void _handleLogin() async {
    if (id.isNotEmpty && pw.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: id,
          password: pw,
        );

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(id)
            .get();

        if (userSnapshot.exists) {
          userAddress = userSnapshot.get("address");
        } else {
          print('사용자 정보가 없습니다.');
        }

        // 저장 여부 확인 및 저장
        if (saveLoginInfo) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('savedId', id);
          await prefs.setString('savedPw', pw);
        }
      } catch (e) {
        print('로그인 실패');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("로그인 실패"),
            content: Text("아이디 또는 비밀번호가 올바르지 않습니다."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("확인"),
              ),
            ],
          ),
        );
        print('Error occurred during login: $e');
      }
    }
  }
  // 다이얼로그를 표시하고 저장 여부를 설정하는 함수
  Future<void> _showSaveLoginInfoDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 정보 저장'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('로그인 정보를 저장하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('예'),
              onPressed: () {
                setState(() {
                  saveLoginInfo = true;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                setState(() {
                  saveLoginInfo = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "ID",
              ),
              onChanged: (value) {
                setState(() {
                  id = value;
                });
              },
            ),
            TextField(
              controller: pwController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "PASSWORD",
              ),
              onChanged: (value) {
                setState(() {
                  pw = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _showSaveLoginInfoDialog(); // 저장 여부 다이얼로그 표시
                _handleLogin();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MapSample(address: userAddress, email: id, firestore: fireStore),
                  ),
                );
              },
              child: Text("보호자 Login"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _showSaveLoginInfoDialog(); // 저장 여부 다이얼로그 표시
                _handleLogin();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeniorLogin(email: id),
                  ),
                );
              },
              child: Text("보호대상자 Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(SignUpPage());
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
