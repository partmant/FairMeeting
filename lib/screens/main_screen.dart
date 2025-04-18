import 'package:flutter/material.dart';
import 'package:fair_front/screens/put_location_screen.dart';
import '../widgets/logo_title.dart';
import 'package:fair_front/screens/login_screen.dart';
import 'package:fair_front/screens/my_info_screen.dart';
import 'package:fair_front/screens/settings_screen.dart';


import 'calender_screen.dart';

class MainmenuScreen extends StatefulWidget {
  const MainmenuScreen({super.key});

  @override
  State<MainmenuScreen> createState() => _MainmenuScreenState();
}

class _MainmenuScreenState extends State<MainmenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow.shade50,
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Center(
              child: LogoTitle(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: [
                    _buildMenuButton(
                      context: context,
                      label: '약속 만들기',
                      subLabel1: '            간편하게',
                      subLabel2: '약속 장소 정하기',
                      icon: Icons.calendar_today,
                      color: Colors.white,
                      textColor: Colors.black,
                      iconColor: Colors.black,
                    ),
                    _buildMenuButton(
                      context: context,
                      label: '약속 캘린더',
                      subLabel1: '내 약속 확인하기',
                      subLabel2: '',
                      icon: Icons.event_available,
                      color: Colors.orange.shade200,
                    ),
                    _buildMenuButton(
                      context: context,
                      label: '내 정보',
                      subLabel1: '개인정보 수정',
                      subLabel2: '',
                      icon: Icons.person,
                      color: Colors.orange.shade200,
                    ),
                    _buildMenuButton(
                      context: context,
                      label: '환경설정',
                      subLabel1: '앱 설정 관리',
                      subLabel2: '',
                      icon: Icons.settings,
                      color: Colors.white,
                      textColor: Colors.black,
                      iconColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required String subLabel1,
    required String subLabel2,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return ElevatedButton(
      onPressed: () {
        if (label == '약속 만들기') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PutLocationScreen()),
          );
        } else if (label == '내 정보') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyInfoPage()),
          );
        } else if (label == '약속 캘린더') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => const AppointmentCalendarScreen()),
          );
        } else if (label == '환경설정')   {
          Navigator.push(
            context,
              MaterialPageRoute(
              builder: (builder) =>  SettingsScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label 버튼을 눌렀습니다.')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Icon(icon, size: 25, color: iconColor),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subLabel1,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subLabel2,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}