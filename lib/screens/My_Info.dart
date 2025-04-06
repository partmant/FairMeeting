import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내 정보',
      home: const MyInfoPage(),
    );
  }
}

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  void _onButtonPressed(String title) {
    print('$title 버튼 클릭됨');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person, color: Colors.black),
            SizedBox(width: 4),
            Text(
              '내 정보',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
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
                onPressed: () => _onButtonPressed("로그인"),
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
                      onPressed: () => _onButtonPressed("친구 목록 보기"),
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
                    _buildOutlinedMenu(Icons.password, '비밀번호 변경'),
                    _buildOutlinedMenu(Icons.lock, '개인 정보 및 보안'),
                    _buildOutlinedMenu(Icons.campaign, '공지사항'),
                    _buildOutlinedMenu(Icons.policy, '약관 및 정책'),
                    _buildOutlinedMenu(Icons.logout, '로그아웃'),
                    _buildOutlinedMenu(Icons.cancel, '회원 탈퇴'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedMenu(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: OutlinedButton(
        onPressed: () => _onButtonPressed(title),
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
