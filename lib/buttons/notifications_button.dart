import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {       //알림 설정 여부 저장 변수
  bool basicNotification = false;
  bool friendNotification = false;
  bool noticeNotification = false;
  bool updateNotification = false;

  Widget buildSectionTitle(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CupertinoSwitch(  // ios 스타일 토글 스위치 사용
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(height: 13, thickness: 1.1, color: Color(0xFFD9C189));
  }       // 구분선 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.notifications_none, color: Colors.black, size: 35),
              SizedBox(width: 8),    // 상단 아이콘과 텍스트 간격
              Text(
                '알림',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(    // 리스트 뷰로 생성
        children: [
          const SizedBox(height: 20),
          buildSectionTitle("기본 알림", basicNotification, (value) {
            setState(() => basicNotification = value); // 상태 업데이트
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "아래와 같은 상황에 알림(push)으로 알려드립니다.\n"
                  "- 약속 확정 시\n"
                  "- 약속 1일 전\n"
                  "- 약속 3시간 전",
              style: TextStyle(fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 15),
          buildDivider(),
          buildSectionTitle("친구 추가 알림", friendNotification, (value) {
            setState(() => friendNotification = value);
          }),
          buildDivider(),
          buildSectionTitle("공지 알림", noticeNotification, (value) {
            setState(() => noticeNotification = value);
          }),
          buildDivider(),
          buildSectionTitle("업데이트 알림", updateNotification, (value) {
            setState(() => updateNotification = value);
          }),
          buildDivider(),
        ],
      ),
    );
  }
}
