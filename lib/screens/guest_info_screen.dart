import 'package:flutter/material.dart';
import 'package:fair_front/screens/login_screen.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 0,top: 22), // 아이콘 + ' 내 정보' 위치 조정
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.person, color: Colors.black87, size: 25),
                SizedBox(width: 8),
                Text(
                  '내 정보',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 로그인 버튼
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.2),
                borderRadius: BorderRadius.circular(10),
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
                    Icon(Icons.login_rounded, color: Colors.black, size: 24,),
                    SizedBox(width: 10),
                    Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // 메뉴 리스트
            SizedBox(
              height: 480,
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
                    _buildOutlinedMenu(context, Icons.password, '비밀번호 변경'),
                    _buildOutlinedMenu(context, Icons.lock, '개인 정보 및 보안'),
                    _buildOutlinedMenu(context, Icons.campaign, '공지사항'),
                    _buildOutlinedMenu(context, Icons.policy, '약관 및 정책'),
                    _buildOutlinedMenu(context, Icons.logout, '로그아웃'),
                    _buildOutlinedMenu(context, Icons.cancel, '회원 탈퇴', isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedMenu(
      BuildContext context,
      IconData icon,
      String title, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: isLast ? 0 : 8),
      child: OutlinedButton(
        onPressed: () => _onButtonPressed(title, context),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD9C189), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
