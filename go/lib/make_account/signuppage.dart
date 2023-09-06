import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go/make_account/user_info_page.dart';
import 'package:go/make_account/fail_signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  String email = ""; // 이메일 정보를 저장할 변수
  String password = "";

  void _handleSignUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: idController.text,
        password: pwdController.text,
      );

      await FirebaseFirestore.instance.collection("Login").doc(email).set({
        "ID": idController.text,
        "PW": pwdController.text,
      });

      await FirebaseFirestore.instance
          .collection("Login")
          .doc(email) // 사용자 고유 UID를 문서 ID로 사용
          .collection("Locations") // 사용자마다 개별 컬렉션 생성
          .add({
        'latitude': 0.0, // 초기값 혹은 필요한 위치 정보
        'longitude': 0.0,
        'timestamp': FieldValue.serverTimestamp(),
      });



      // 회원가입 성공 후 필요한 동작 추가
      // 예를 들어, 회원가입 완료 화면으로 이동하거나, 회원가입 완료 메시지를 띄워줄 수 있습니다.
      Navigator.push(
        context,
        MaterialPageRoute(
          //builder: (context) => SuccessPage(email: userCredential.user?.email),
          builder: (context) => UserInfoPage(email: email),
        ),
      );
      print('회원가입 성공: ${userCredential.user?.email}');

      //회원가입 실패
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('Unknown error occurred.: $e');
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FailPage(),
        ),
      );

    } catch (e) {
      print('Error occurred during sign up. :$e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FailPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("계정 정보 입력"),),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: pwdController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleSignUp,
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
