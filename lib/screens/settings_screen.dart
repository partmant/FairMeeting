import 'package:flutter/material.dart';
import '../buttons/notifications_button.dart';


class SettingsScreen extends StatelessWidget {
  final List<_SettingsItem> items = [
    _SettingsItem(Icons.notifications_none, '알림'),
    _SettingsItem(Icons.brightness_6, '화면'),
    _SettingsItem(Icons.near_me_outlined, '위치 권한 관리'),
    _SettingsItem(Icons.language, '언어 / language'),
    _SettingsItem(Icons.headset_mic, '고객센터'),
    _SettingsItem(Icons.info_outline, 'FAIR-MEETING 정보'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Padding(
          padding: const EdgeInsets.only(top: 25), // 설정 아이콘 + 텍스트 상하 위치 조정
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings,
                color: Colors.black,
                size: 28, // 아이콘 크기
              ),
              SizedBox(width: 8),
              Text(
                '설정   ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25, // 텍스트 크기
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [SizedBox(width: 48)],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'FAIR',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'Itim',
                      color: Color(0xFFD9C189).withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'MEETING',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'Itim',
                      color: Color(0xFFD9C189).withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 55),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: items.map((item) => _buildItemButton(item, context)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemButton(_SettingsItem item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFD9C189), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: () {
            if (item.title == '알림') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.title} 버튼 클릭됨')),
              );
            }
          },
          child: Row(
            children: [
              Icon(item.icon, color: Colors.black),
              SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;

  _SettingsItem(this.icon, this.title);
}
