import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class KakaoLoginService {
  static Future<bool> login(BuildContext context) async {
    final userController = context.read<UserController>();

    /* 이미 로그인 한 사람 처리 시
    if (!userController.isGuest) {
      print('이미 로그인된 사용자입니다.');
      return false;
    }
    */

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

      userController.setLoggedIn();
      return true;

    } catch (e) {
      print('카카오 로그인 실패: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $e')),
        );
      }
      return false;
    }
  }
}
