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
          OAuthToken? token;
          User? user;

          // 카카오톡 설치 여부 확인
          bool isInstalled = await isKakaoTalkInstalled();

          if (isInstalled) {
            try {
              // 카카오톡 앱을 통한 로그인 시도
              token = await UserApi.instance.loginWithKakaoTalk();
              print('카카오톡으로 로그인 성공: ${token.accessToken}');
            } catch (error) {
              // 실패 시, 웹뷰 방식 로그인 시도
              print('카카오톡 로그인 실패, WebView로 로그인 시도');
              token = await UserApi.instance.loginWithKakaoAccount();
              print('카카오 계정으로 로그인 성공: ${token.accessToken}');
            }
          } else {
            // 카카오톡 미설치 시, 웹 로그인
            token = await UserApi.instance.loginWithKakaoAccount();
            print('카카오 계정으로 로그인 성공: ${token.accessToken}');
          }

          // 로그인 후 토큰이 있다면 사용자 정보 요청
          if (token != null) {
            user = await UserApi.instance.me();

            String userId = user.id.toString();
            String name = user.kakaoAccount?.profile?.nickname ?? '사용자';
            String imageUrl = user.kakaoAccount?.profile?.profileImageUrl ?? '';
            
            userController.setLoggedIn(name: name, profileUrl: imageUrl, userId: userId,);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainmenuScreen()),
            );
          } else {
            print('로그인 실패: 토큰 없음');
          }
        } catch (e) {
          print('로그인 도중 예외 발생: $e');

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('카카오 로그인 실패: $e')),
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
