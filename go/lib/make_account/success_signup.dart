
import 'package:flutter/material.dart';
import 'package:go/make_account/loginpage.dart';

class SuccessPage extends StatelessWidget {
  final String? email; // 이메일 정보를 저장하는 변수

  SuccessPage({required this.email}); // 생성자를 통해 이메일 정보 전달받음

  String login="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Success"),),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green,),
            SizedBox(height: 16.0),
            Text(
              "회원가입이 성공적으로 완료되었습니다!",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              "이메일: ${email ?? 'Unknown'}",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 로그인 페이지로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(email: login),
                  ),
                );
              },
              child: Text("로그인 하러 가기"),
            ),
          ],
        ),
      ),
    );
  }
}
