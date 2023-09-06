import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeniorMemo extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  SeniorMemo({required this.email});

  @override
  _SeniorMemoState createState() => _SeniorMemoState();
}

class _SeniorMemoState extends State<SeniorMemo> {
  FirebaseFirestore fireStore=FirebaseFirestore.instance;
  List<String> memoList = [];

  @override
  void initState() {
    super.initState();
    _loadMemoList();
  }

  Future<void> _loadMemoList() async {
    try {
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection("users").doc(widget.email).get();

      if (userDocSnapshot.exists) {
        dynamic savedMemoList = userDocSnapshot.get("memoList");

        if (savedMemoList != null) {
          setState(() {
            memoList = savedMemoList.cast<String>(); // Convert to List<String>
          });
        }
      }
    } catch (e) {
      print("Error loading memo list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호자에게 전달받은 메모")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: memoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(memoList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}