import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/notification_plugin.dart';

class NotificationService {
  // 싱글톤
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// 즉시(Immediate) 알림
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_channel',
          '즉시 알림',
          channelDescription: '바로 보여주는 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// 하루 전 알림 예약
  Future<void> scheduleDailyBefore({
    required int id,
    required String title,
    required String body,
    required DateTime eventDateTime,
  }) async {
    // 0) 약속 시간이 이미 지났으면 스킵
    final tzNow   = tz.TZDateTime.now(tz.local);
    final tzEvent = tz.TZDateTime.from(eventDateTime, tz.local);
    if (tzEvent.isBefore(tzNow)) {
      debugPrint('⚠️ [스킵] 이미 지난 약속(id=$id) 알림 미등록');
      return;
    }

    // 1) “하루 전” 시각 계산
    final scheduledDt  = eventDateTime.subtract(const Duration(days: 1));
    final tzScheduled  = tz.TZDateTime.from(scheduledDt, tz.local);

    // 2) 하루 전 시점이 지났으면 즉시 알림
    if (tzScheduled.isBefore(tzNow)) {
      debugPrint('⚡ 즉시 알림: id=$id');
      await showImmediateNotification(
        id:    id + 100000, // offset을 더하면 id 충돌 방지
        title: title,
        body:  body,
      );
      return;
    }

    // 3) Android 정확 알람 권한 요청 및 스케줄 모드 결정
    bool useExact = true;
    if (Platform.isAndroid) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      try {
        final granted = await androidImpl?.requestExactAlarmsPermission();
        useExact = granted == true;
      } catch (_) {
        useExact = false;
      }
    }
    final scheduleMode = useExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    debugPrint('🔔 예약: id=$id, at=$tzScheduled, mode=${useExact ? '정확' : '대략'}');

    // 4) 실제 예약
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'calendar_channel',
          '캘린더 알림',
          channelDescription: '약속 하루 전 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(categoryIdentifier: 'calendar'),
        macOS: DarwinNotificationDetails(categoryIdentifier: 'calendar'),
      ),
      androidScheduleMode: scheduleMode,
    );
  }

  /// 단일 알림 취소
  Future<void> cancelNotification(int id) =>
      flutterLocalNotificationsPlugin.cancel(id);

  /// 예약된 모든 알림 취소
  Future<void> cancelAllNotifications() =>
      flutterLocalNotificationsPlugin.cancelAll();

  /// iOS/macOS 권한 요청
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}
