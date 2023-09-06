import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProtectorMemo extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  ProtectorMemo({required this.email});

  @override
  _ProtectorMemoState createState() => _ProtectorMemoState();
}

class _ProtectorMemoState extends State<ProtectorMemo> {
  int memoCounter = 1;
  String memo = '';
  List<String> memoList = [];
  TextEditingController _memoController = TextEditingController();

  void _handleSaveUserInfo() {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(widget.email);

    userDocRef.update({
      "memoList": FieldValue.arrayUnion([_memoController.text]),
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMemoList();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호대상자에게 메모 전달")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _memoController,
                onChanged: (value) {
                  setState(() {
                    memo = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '메모를 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveMemo();
                _handleSaveUserInfo();
              },
              child: Text('저장'),
            ),
            SizedBox(height: 20),
            Text(
              '메모 내용:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              memo,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '저장된 메모 목록:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: memoList.length,
                itemBuilder: (context, index) {
                  String memoWithNumber = '${memoCounter++}. ${memoList[index]}';
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

  void _saveMemo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    memoList.add(memo);
    prefs.setStringList('memoList', memoList);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('메모가 저장되었습니다.'),
      duration: Duration(seconds: 2),
    ));
    _memoController.clear();
    setState(() {
      memo = '';
    });

    memoCounter = 1;

    // 새로운 메모를 저장한 후에 목록을 다시 불러옴
    _loadMemoList();
  }

  void _loadMemoList() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection("users").doc(widget.email).get();

    if (userDocSnapshot.exists) {
      List<dynamic>? savedMemoList = userDocSnapshot.get("memoList");

      if (savedMemoList != null) {
        setState(() {
          memoList = savedMemoList.cast<String>(); // Convert to List<String>
        });
      }
    }
  }
}