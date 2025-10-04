import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/notification_plugin.dart';
import '../services/notification_service.dart';
import '../widgets/logo_title.dart';

// 백그라운드 알림 탭 처리 엔트리 포인트
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // 백그라운드에서 알림이 탭됐을 때 추가 로직이 필요하면 여기에 구현
}

class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1) 타임존 설정
    tz.initializeTimeZones();
    final String name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));

    // 2) 알림 플러그인 초기화
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
      ),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 3) iOS/macOS 권한 요청
    await NotificationService().requestPermissions();

    // 4) Android 권한 요청 및 채널 설정
    if (Platform.isAndroid) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!;

      // Android 13(API 33)+ POST_NOTIFICATIONS 권한 요청
      final bool? notifGranted =
      await androidImpl.requestNotificationsPermission();
      debugPrint('🔔 POST_NOTIFICATIONS granted? $notifGranted');

      // Notification 채널 생성
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'immediate_channel',
          '즉시 알림',
          description: '바로 보여주는 알림',
          importance: Importance.max,
        ),
      );
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'calendar_channel',
          '캘린더 알림',
          description: '약속 하루 전 알림',
          importance: Importance.max,
        ),
      );
    }

    // 5) 초기화 완료 후 메인 화면으로 이동
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              LogoTitle(),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
