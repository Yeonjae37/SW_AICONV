import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProtectorProfile extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  ProtectorProfile({required this.email});

  @override
  _ProtectorProfileState createState() => _ProtectorProfileState();
}

class _ProtectorProfileState extends State<ProtectorProfile> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userInfo;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController radiusController = TextEditingController();
  TextEditingController cmController = TextEditingController();
  TextEditingController kgController = TextEditingController();
  TextEditingController phone1Controller = TextEditingController();
  TextEditingController phone1RelationController = TextEditingController();
  TextEditingController phone2Controller = TextEditingController();
  TextEditingController phone2RelationController = TextEditingController();
  TextEditingController phone3Controller = TextEditingController();
  TextEditingController phone3RelationController = TextEditingController();
  TextEditingController protectorNameController = TextEditingController();
  TextEditingController protectorAgeController = TextEditingController();
  TextEditingController protectorRelationController = TextEditingController();

  // Add more controllers for other fields

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
          nameController.text = userInfo!['name'] ?? '';
          ageController.text = userInfo!['age']?.toString() ?? '';
          addressController.text = userInfo!['address'] ?? '';
          radiusController.text = userInfo!['radius']?.toString() ?? '';
          cmController.text = userInfo!['cm']?.toString() ?? '';
          kgController.text = userInfo!['kg']?.toString() ?? '';
          phone1Controller.text = userInfo!['phone1']?.toString() ?? '';
          phone1RelationController.text = userInfo!['phone1Relation']?.toString() ?? '';
          phone2Controller.text = userInfo!['phone2']?.toString() ?? '';
          phone2RelationController.text = userInfo!['phone2Relation']?.toString() ?? '';
          phone3Controller.text = userInfo!['phone3']?.toString() ?? '';
          phone3RelationController.text = userInfo!['phone3Relation']?.toString() ?? '';
          protectorNameController.text = userInfo!['protectorName'] ?? '';
          protectorAgeController.text = userInfo!['protectorAge']?.toString() ?? '';
          protectorRelationController.text = userInfo!['protectorRelation'] ?? '';
          // Initialize other controllers for other fields
        });
      }
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        await firestore.collection("users").doc(widget.email).update({
          'name': nameController.text,
          'age': int.tryParse(ageController.text),
          'address':addressController.text,
          'radius':int.tryParse(radiusController.text),
          'cm':int.tryParse(cmController.text),
          'kg':int.tryParse(kgController.text),
          'phone1':int.tryParse(phone1Controller.text),
          'phone1Relation':phone1RelationController.text,
          'phone2':int.tryParse(phone2Controller.text),
          'phone2Relation':phone2RelationController.text,
          'phone3':int.tryParse(phone3Controller.text),
          'phone3Relation':phone3RelationController.text,
          'protectorName':protectorNameController.text,
          'protectorAge':int.tryParse(protectorAgeController.text),
          'protectorRelation':protectorRelationController.text,
          // Update other fields
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("정보가 업데이트되었습니다.")));
      } catch (e) {
        print("Error updating user info: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("내 정보")),
      body: Center(
        child: userInfo != null
            ? SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "[보호대상자 정보]",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '이름'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: '나이'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: '주소'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: radiusController,
                  decoration: InputDecoration(labelText: '반경'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: cmController,
                  decoration: InputDecoration(labelText: '키'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: kgController,
                  decoration: InputDecoration(labelText: '몸무게'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: phone1Controller,
                  decoration: InputDecoration(labelText: '1.비상연락망'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: phone1RelationController,
                  decoration: InputDecoration(labelText: '1.관계'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: phone2Controller,
                  decoration: InputDecoration(labelText: '2.비상연락망'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: phone2RelationController,
                  decoration: InputDecoration(labelText: '2.관계'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: phone3Controller,
                  decoration: InputDecoration(labelText: '3.비상연락망'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: phone3RelationController,
                  decoration: InputDecoration(labelText: '3.관계'),
                  // Add validation if needed
                ),
                SizedBox(height: 20),
                Text(
                  "[보호자 정보]",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: protectorNameController,
                  decoration: InputDecoration(labelText: '보호자 이름'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: protectorAgeController,
                  decoration: InputDecoration(labelText: '보호자 나이'),
                  // Add validation if needed
                ),
                TextFormField(
                  controller: protectorRelationController,
                  decoration: InputDecoration(labelText: '보호자대상자와의 관계'),
                  // Add validation if needed
                ),
                // Add more TextFormField widgets for other fields
                ElevatedButton(
                  onPressed: _updateUserInfo,
                  child: Text("정보 업데이트"),
                ),
                // ...
              ],
            ),
          ),
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}

