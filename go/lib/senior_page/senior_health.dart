import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class SeniorHealth extends StatefulWidget {
  final String email; // 회원가입 페이지에서 받아온 이메일 정보

  SeniorHealth({required this.email});

  @override
  _SeniorHealthState createState() => _SeniorHealthState();
}

class Alarm {
  String title;
  TimeOfDay time;

  Alarm({required this.title, required this.time});
}

class _SeniorHealthState extends State<SeniorHealth> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  FirebaseFirestore fireStore=FirebaseFirestore.instance;
  List<Alarm> alarmList = [];

  @override
  void initState() {
    super.initState();
    _loadAlarmList();
    _startCheckingTimeMatch();
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

      print("알람 시간: $alarmDateTime, 현재 시간: $now");

    }
  }

  Future<void> _loadAlarmList() async {
    try {
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection("users").doc(widget.email).get();

      if (userDocSnapshot.exists) {
        dynamic savedAlarmList = userDocSnapshot.get("alarmList");

        if (savedAlarmList != null && savedAlarmList is List) {
          List<Alarm> loadedAlarms = [];

          for (var alarmData in savedAlarmList) {
            if (alarmData is Map<String, dynamic>) {
              Alarm alarm = Alarm(
                title: alarmData['title'] ?? '', // Replace 'title' with actual key
                time: TimeOfDay(
                  hour: alarmData['hour'] ?? 0, // Replace 'hour' with actual key
                  minute: alarmData['minute'] ?? 0, // Replace 'minute' with actual key
                ),
              );

              loadedAlarms.add(alarm);
            }
          }


          setState(() {
            alarmList = loadedAlarms;
            print(savedAlarmList);
          });
        }
      }
    } catch (e) {
      print("Error loading alarm list: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보호자에게 전달받은 약 알람")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: alarmList.length,
                itemBuilder: (context, index) {
                  final alarm = alarmList[index];
                  return ListTile(
                    title: Text(alarm.title),
                    subtitle: Text('알람 시간: ${alarm.time.format(context)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 여기에 원하는 위젯을 추가하세요
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