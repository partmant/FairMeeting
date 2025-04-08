import 'package:flutter/material.dart';
import 'package:fair_front/screens/login_screen.dart';
import 'package:fair_front/widgets/go_back.dart';  // 공통 AppBar import

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  void _onButtonPressed(String title, BuildContext context) {
    print('$title 버튼 클릭됨');

    if (title == "로그인") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
    // 나중에 로그아웃, 회원탈퇴도 여기에 추가할 수 있음
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildCommonAppBar(context, title:'내 정보'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 로그인 버튼 형태 사용자 정보 카드
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _onButtonPressed("로그인", context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.login_rounded, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 친구 목록 보기 + 줄
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _onButtonPressed("친구 목록 보기", context),
                      icon: const Icon(Icons.people, color: Colors.black, size: 16),
                      label: const Text(
                        '친구 목록 보기',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                      ),
                    ),
                    Container(
                      height: 1.5,
                      width: 110,
                      color: const Color(0xFFD9C189),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 메뉴 리스트
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  children: [
                    _buildOutlinedMenu(context, Icons.password, '비밀번호 변경'),
                    _buildOutlinedMenu(context, Icons.lock, '개인 정보 및 보안'),
                    _buildOutlinedMenu(context, Icons.campaign, '공지사항'),
                    _buildOutlinedMenu(context, Icons.policy, '약관 및 정책'),
                    _buildOutlinedMenu(context, Icons.logout, '로그아웃'),
                    _buildOutlinedMenu(context, Icons.cancel, '회원 탈퇴'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedMenu(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: OutlinedButton(
        onPressed: () => _onButtonPressed(title, context),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD9C189), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
