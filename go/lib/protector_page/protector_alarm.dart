import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class Alarm {
  final int id;
  String title;
  TimeOfDay time;
  bool isOn;

  Alarm({required this.id, required this.title, required this.time, this.isOn = true});
}

class ProtectorAlarm extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  ProtectorAlarm({required this.email});

  @override
  _ProtectorAlarmState createState() => _ProtectorAlarmState();
}

class _ProtectorAlarmState extends State<ProtectorAlarm> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  List<Alarm> alarmList = [];
  TextEditingController _alarmController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _uniqueId = 1;

  void _handleSaveUserInfo() async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(widget.email);

    List<Map<String, dynamic>> alarmMapList = alarmList
        .where((alarm) => alarm.isOn) // 삭제되지 않은 알람만 선택
        .map((alarm) => {
            'id': alarm.id,
            'title': alarm.title,
            'hour': alarm.time.hour,
            'minute': alarm.time.minute,
            'isOn': alarm.isOn,
          }).toList();

    await userDocRef.update({
      "alarmList": FieldValue.arrayUnion(alarmMapList),
    });
  }

  @override
  void initState() {
    super.initState();
    // 알림 초기화
    _initializeNotifications();
    // 30초마다 시간 일치 확인
    _startCheckingTimeMatch();
    // 앱을 실행할 때, 기존의 알람 정보를 파이어베이스에서 가져옵니다.
    _loadUserAlarms();
  }


  // 알림 초기화
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // 앱 아이콘으로 설정
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 기존의 알람 정보를 파이어베이스에서 불러오는 함수
  void _loadUserAlarms() async {
    DocumentSnapshot userDocSnapshot =
      await FirebaseFirestore.instance.collection("users").doc(widget.email).get();

    if (userDocSnapshot.exists) {
      Map<String, dynamic>? userData = userDocSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        List<dynamic>? alarmsFromFirebase = userData["alarmList"];

        if (alarmsFromFirebase != null) {
          List<Alarm> loadedAlarms = alarmsFromFirebase.map((alarm) {
            return Alarm(
              id: alarm['id'],
              title: alarm['title'],
              time: TimeOfDay(hour: alarm['hour'], minute: alarm['minute']),
              isOn: alarm['isOn'],
            );
          }).toList();

          setState(() {
            alarmList = loadedAlarms;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _alarmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호대상자의 약 알람 설정")),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _alarmController,
                      decoration: InputDecoration(
                        hintText: '알람 제목을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectTimeAndAddAlarm();
                      _handleSaveUserInfo();
                    },
                    child: Text('추가'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              '알람 목록:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: alarmList.length,
                itemBuilder: (context, index) {
                  final alarm = alarmList[index];
                  return ListTile(
                    title: Text(alarm.title),
                    subtitle: Text(
                      '알람 시간: ${alarm.time.format(context)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editAlarm(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteAlarm(index);
                          },
                        ),
                        Switch(
                          value: alarm.isOn,
                          onChanged: (value) {
                            setState(() {
                              alarmList[index].isOn = value;
                            });
                            _isOnUpdateFromFirebase(index, value);
                            _handleSaveUserInfo();
                            _loadUserAlarms();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 30초마다 설정된 알람 시간과 현재 시간을 비교
  void _startCheckingTimeMatch() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      print("30초 경과");
      _checkTimeMatch();
    });
  }

  // 알람 시간과 현재 시간을 비교하고 일치할 경우 알림 출력
  void _checkTimeMatch() {
    final now = DateTime.now();
    for (var alarm in alarmList) {
      if (now.hour == alarm.time.hour && now.minute == alarm.time.minute) {
        //_showNotificationDialog(alarm.title);
        FlutterLocalNotification.showNotification(alarm.title);
      }

      final alarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.time.hour,
        alarm.time.minute,
      );

      //print("알람 시간: $alarmDateTime, 현재 시간: $now");

    }
  }

  Future<void> _selectTimeAndAddAlarm() async {
    String title = _alarmController.text.trim();
    if (title.isEmpty) {
      return;
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final newAlarm = Alarm(id: _uniqueId, title: title, time: pickedTime);
        alarmList.add(newAlarm);
        _uniqueId++;
        _alarmController.clear();

        // Schedule push notification for the selected time
        _scheduleNotification(newAlarm);

        // 저장된 알람 정보를 파이어베이스에 업데이트
        _handleSaveUserInfo();

        // 파이어베이스에서 알람 정보 다시 불러오기
        _loadUserAlarms();
      });
    }
  }

  void _editAlarm(int index) async {
    final alarm = alarmList[index];
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: alarm.time,
    );

    if (pickedTime != null) {
      setState(() {
        alarmList[index].time = pickedTime;

        // 수정된 알람 정보를 파이어베이스에 업데이트
        _handleSaveUserInfo();

        // 파이어베이스에서 알람 정보 다시 불러오기
        _loadUserAlarms();
      });
    }
  }

  void _deleteAlarmFromFirebase(int alarmId) async {
    DocumentReference userDocRef =
    FirebaseFirestore.instance.collection("users").doc(widget.email);

    List<Map<String, dynamic>> updatedAlarmMapList = alarmList
        .where((alarm) => alarm.id != alarmId) // 해당 ID를 가진 알람 제외
        .map((alarm) => {
      'id': alarm.id,
      'title': alarm.title,
      'hour': alarm.time.hour,
      'minute': alarm.time.minute,
      'isOn': alarm.isOn,
    }).toList();

    await userDocRef.update({
      "alarmList": updatedAlarmMapList,
    });
  }

  void _isOnUpdateFromFirebase(int index, bool value) async {
    DocumentReference userDocRef =
    FirebaseFirestore.instance.collection("users").doc(widget.email);

    Alarm updatedAlarm = alarmList[index]; // 해당 인덱스의 알람 가져오기

    List<Map<String, dynamic>> updatedAlarmMapList = alarmList
        .map((alarm) => {
      'id': alarm.id,
      'title': alarm.title,
      'hour': alarm.time.hour,
      'minute': alarm.time.minute,
      //'isOn': alarm.id == updatedAlarm.id ? updatedAlarm.isOn : alarm.isOn,
      'isOn': alarm.id == updatedAlarm.id ? value : alarm.isOn,
    }).toList();

    await userDocRef.update({
      "alarmList": updatedAlarmMapList,
    });
  }



  void _deleteAlarm(int index) {
    final deletedAlarm = alarmList[index]; // 삭제할 알람 객체 가져오기
    _deleteAlarmFromFirebase(deletedAlarm.id); // 파이어베이스에서 알람 삭제

    setState(() {
      alarmList.removeAt(index);
      // 삭제된 알람 정보를 파이어베이스에서 업데이트
      _handleSaveUserInfo();
      // 파이어베이스에서 알람 정보 다시 불러오기
      _loadUserAlarms();
    });
  }

  Future<void> _scheduleNotification(Alarm alarm) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id', // Replace with your own channel ID
      'your channel name', // Replace with your own channel name
      //'your channel description', // Replace with your own channel description
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('your_custom_sound'), // 소리 파일 추가 필요
    );

    //const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      //iOS: iOSPlatformChannelSpecifics,
    );

    final now = DateTime.now();

    // 여기에 사용할 타임존을 선택하여 입력하세요
    final location = getLocation('your_time_zone');

    final scheduledDate = TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      'Alarm: ${alarm.title}',
      'It\'s time for your alarm!',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    _showNotificationDialog(alarm.title);
  }

  Future<void> _showNotificationDialog(String title) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alarm: $title'),
          content: Text('It\'s time for your alarm!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // 알림 소리를 중단하고 메시지 창을 닫습니다.
                flutterLocalNotificationsPlugin.cancelAll();
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');

    IOSInitializationSettings iosInitializationSettings =
    const IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showNotification(String title) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: IOSNotificationDetails(badgeNumber: 1));

    await flutterLocalNotificationsPlugin.show(
        0, '[알람]', '"${title}"', notificationDetails);
  }
}
