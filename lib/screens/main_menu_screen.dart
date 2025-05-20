import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'put_location_screen.dart';
import 'calender_screen.dart';
import 'my_info_screen.dart';
import 'guest_info_screen.dart';
import 'settings_screen.dart';
import '../widgets/logo_title.dart';
import '../buttons/main_menu_button.dart';

class MainmenuScreen extends StatelessWidget {
  const MainmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'label': '약속 만들기',
        'sub': '간편하게\n약속 장소 정하기',
        'icon': Icons.calendar_today,
        'color': Color(0xFFD9C189),
        'textColor': Colors.white,
        'subTextColor': Colors.black,
        'onTap': () => Navigator.push(context,MaterialPageRoute(builder: (_) => const PutLocationScreen(),settings: const RouteSettings(name: '/put-location'),),)
      },
      {
        'label': '약속 캘린더',
        'sub': '내 약속\n확인하기',
        'icon': Icons.event_available,
        'color': Colors.white,
        'textColor': Colors.black,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  AppointmentCalendarScreen())),
      },
      {
        'label': '내 정보',
        'sub': '개인정보 수정',
        'icon': Icons.person,
        'color': Colors.white,
        'textColor': Colors.black,
        'onTap': () {
          final isGuest = context.read<UserController>().isGuest;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isGuest ? const GuestInfoPage() : const MyInfoPage(),
            ),
          );
        }
      },
      {
        'label': '환경설정',
        'sub': '앱 설정 관리',
        'icon': Icons.settings,
        'color': Color(0xFFD9C189),
        'textColor': Colors.white,
        'subTextColor': Colors.black,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
      },
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF8E1).withAlpha(102),     // 연한 노란색, 40% 투명도 적용
              Color(0xFFFFD54F).withAlpha(102),     // 좀 더 진한 노란색, 40% 투명도 적용
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Center(child: LogoTitle()),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: menuItems.map((item) => MainMenuButton(data: {
                    ...item,
                    'labelStyle': const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  })).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}