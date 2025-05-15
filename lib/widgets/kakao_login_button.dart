import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/screens/main_menu_screen.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {

        final userController = context.read<UserController>();

        try {
          OAuthToken token;

          bool isInstalled = await isKakaoTalkInstalled();
          if (isInstalled) {
            try {
              token = await UserApi.instance.loginWithKakaoTalk();
              print('카카오톡으로 로그인 성공: ${token.accessToken}');
            } catch (error) {
              print('카카오톡 로그인 실패, WebView로 로그인 시도');
              token = await UserApi.instance.loginWithKakaoAccount();
              print('카카오 계정으로 로그인 성공: ${token.accessToken}');
            }
          } else {
            token = await UserApi.instance.loginWithKakaoAccount();
            print('카카오 계정으로 로그인 성공: ${token.accessToken}');
          }

          final user = await UserApi.instance.me();
          print('카카오 로그인 성공: ${user.kakaoAccount?.email}');

          // 회원으로 변경
          userController.setLoggedIn();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MainmenuScreen()),
          );
        } catch (e) {
          print('카카오 로그인 실패: $e');

        }
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '카카오톡으로 로그인',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
