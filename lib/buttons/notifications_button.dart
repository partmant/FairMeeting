// lib/buttons/notifications_button.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';
import 'package:fair_front/services/notification_service.dart';
import 'package:fair_front/models/appointment_dto.dart';

import '../screens/login_screen.dart';
import '../utils/notification_plugin.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool basicNotification = false;
  bool friendNotification = false;
  bool noticeNotification = false;
  bool updateNotification = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs   = await SharedPreferences.getInstance();
    final userCtrl = Provider.of<UserController>(context, listen: false);
    final kakaoId  = userCtrl.userId;

    setState(() {
      basicNotification = (kakaoId != null)
          ? prefs.getBool('$kakaoId-basicNotification') ?? false
          : false;
      friendNotification = prefs.getBool('friendNotification') ?? false;
      noticeNotification = prefs.getBool('noticeNotification') ?? false;
      updateNotification = prefs.getBool('updateNotification') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget buildSectionTitle(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget buildDivider() =>
      const Divider(height: 13, thickness: 1.1, color: Color(0xFFD9C189));

  @override
  Widget build(BuildContext context) {
    final userCtrl = Provider.of<UserController>(context, listen: false);
    final isLoggedIn = userCtrl.userId != null;
    final kakaoId = userCtrl.userId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none, color: Colors.black, size: 35),
              SizedBox(width: 8),
              Text('알림',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25)),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // 기본 알림
          buildSectionTitle('기본 알림', basicNotification, (value) async {
            if (!isLoggedIn && value) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
            setState(() => basicNotification = value);
            if (kakaoId != null) {
              await _saveSetting('$kakaoId-basicNotification', value);
            }

            if (basicNotification) {
              final list = await AppointmentService.getAppointments(kakaoId!);
              debugPrint('🙋‍♂️ 가져온 약속 수: ${list.length}');
              for (final appt in list) {
                final d = appt.date;
                final parts = appt.time.split(':').map(int.parse).toList();
                final eventDt = DateTime(d.year, d.month, d.day, parts[0], parts[1]);

                await NotificationService().scheduleDailyBefore(
                  id:            appt.id!,
                  title:         '내일 약속: ${appt.location}',
                  body:          DateFormat('yyyy-MM-dd HH:mm').format(eventDt) +
                      ' 약속이 있습니다.',
                  eventDateTime: eventDt,
                );
              }
            } else {
              await NotificationService().cancelAllNotifications();
            }

            final pending = await flutterLocalNotificationsPlugin
                .pendingNotificationRequests();
            debugPrint('⏳ 보류 중인 알림 개수: ${pending.length}');
            for (final req in pending) {
              debugPrint('• id=${req.id}, title=${req.title}, body=${req.body}');
            }
          }),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '아래와 같은 상황에 알림(push)으로 알려드립니다.\n'
                  '- 약속 확정 시\n'
                  '- 약속 1일 전\n'
                  '- 약속 3시간 전',
              style: TextStyle(fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 15),
          buildDivider(),

          // 친구 추가 알림
          buildSectionTitle('친구 추가 알림', friendNotification, (value) {
            setState(() => friendNotification = value);
            _saveSetting('friendNotification', value);
          }),
          buildDivider(),

          // 공지 알림
          buildSectionTitle('공지 알림', noticeNotification, (value) {
            setState(() => noticeNotification = value);
            _saveSetting('noticeNotification', value);
          }),
          buildDivider(),

          // 업데이트 알림
          buildSectionTitle('업데이트 알림', updateNotification, (value) {
            setState(() => updateNotification = value);
            _saveSetting('updateNotification', value);
          }),
          buildDivider(),
        ],
      ),
    );
  }
}
