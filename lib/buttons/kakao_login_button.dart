import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/kakao_login_service.dart';
import 'package:fair_front/screens/main_menu_screen.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = context.read<UserController>();

    return GestureDetector(
      onTap: () async {
        try {
          // 1) 로그인 + 서버 등록 (비동기)
          final user = await KakaoLoginService.loginAndRegister();

          // 2) 로컬 상태 업데이트 (동기)
          userCtrl.setLoggedIn(
            userId:     user.kakaoId,
            name:       user.nickname,
            profileUrl: user.profileImageUrl,
          );
          // 화면 전환
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainmenuScreen()),
            );
          }
        } catch (e) {
          print('로그인/등록 오류: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
            );
          }
        }
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: const Center(
          child: Text(
            '카카오톡으로 로그인',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
