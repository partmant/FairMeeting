import 'package:flutter/material.dart';
import 'package:fair_front/screens/login_screen.dart';
import 'package:fair_front/buttons/info_menu_button.dart';
import 'package:fair_front/widgets/get_login_page.dart';
import 'package:fair_front/widgets/info_appbar.dart';

class GuestInfoPage extends StatelessWidget {
  const GuestInfoPage({super.key});

  void _onButtonPressed(String title, BuildContext context) {
    print('$title 버튼 클릭됨');

    if (title == "로그인") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const InfoAppBar(title: '내 정보'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const GetLogin(),
            const SizedBox(height: 50),

            // 메뉴 리스트
            SizedBox(
              height: 250,
              child: Container(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    InfoMenuButton(
                      icon: Icons.lock,
                      title: '개인 정보 및 보안',
                      onPressed: () => _onButtonPressed('개인 정보 및 보안', context),
                    ),
                    InfoMenuButton(
                      icon: Icons.campaign,
                      title: '공지사항',
                      onPressed: () => _onButtonPressed('공지사항', context),
                    ),
                    InfoMenuButton(
                      icon: Icons.policy,
                      title: '약관 및 정책',
                      onPressed: () => _onButtonPressed('약관 및 정책', context),
                      isLast: true,
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
}
