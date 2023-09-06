import 'package:flutter/material.dart';

class FailPage extends StatefulWidget {
  @override
  _FailPageState createState() => _FailPageState();
}

class _FailPageState extends State<FailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("회원가입에 실패하셨습니다."),
    );
  }
}