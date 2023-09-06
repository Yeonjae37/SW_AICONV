import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go/make_account/loginpage.dart';

class LandingPage extends StatefulWidget {
  String email = "";

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    Timer(Duration(seconds: 3),(){
      Get.offAll(LoginPage(email: widget.email));
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width:MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset('assets/image/title_homecoming.jpg', fit: BoxFit.cover,)
      )
    );
  }
}