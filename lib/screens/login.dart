import 'package:flutter/material.dart';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
// import 'package:naver_login/naver_login.dart';

// 위젯들 import
import '../widgets/kakao_login_button.dart';
import '../widgets/naver_login_button.dart';
import '../widgets/logo_title.dart';
import '../widgets/text_action_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  bool stayLoggedIn = false;

  void handleLogin() {
    final id = idController.text;
    final pw = pwController.text;

    // 로그인 정보 입력 확인용 출력문
    print('ID: $id, PW: $pw');
  }

  // 카카오 로그인 함수
  Future<void> kakaoLogin() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('카카오 로그인 성공: ${token.accessToken}');

      // 사용자 정보 가져오기
      final user = await UserApi.instance.me();
      print('유저 이메일: ${user.kakaoAccount?.email}');   // 현재 이메일 받을 권한이 없으므로, null로 출력됨
    } catch (e) {
      print('카카오 로그인 실패: $e');
    }
  }

  // 네이버 로그인 함수
  void naverLogin() {
    // 네이버 api 승인되면 구현
    print('네이버 로그인 버튼 눌림 확인용 출력문');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const LogoTitle(),
              const SizedBox(height: 40),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: '아이디',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                children: [
                  // 로그인 상태 유지 체크 시, DB 저장 절차 구현 필요
                  Checkbox(
                    value: stayLoggedIn,
                    onChanged: (value) {
                      setState(() {
                        stayLoggedIn = value!;
                      });
                    },
                  ),
                  const Text('로그인 상태 유지'),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9C189),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text('로그인', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 25),

              // 각각 버튼 눌렸을 때, 기능 구현 필요
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextActionButton(
                    label: '아이디 찾기',
                    onTap: () => print('아이디 찾기 눌림'),
                  ),
                  const Text(' | ', style: TextStyle(color: Colors.grey)),
                  TextActionButton(
                    label: '비밀번호 찾기',
                    onTap: () => print('비밀번호 찾기 눌림'),
                  ),
                  const Text(' | ', style: TextStyle(color: Colors.grey)),
                  TextActionButton(
                    label: '회원가입',
                    onTap: () => print('회원가입 눌림'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextActionButton(
                label: '비회원 로그인',
                onTap: () => print('비회원 로그인 눌림'),
              ),

              const SizedBox(height: 20),
              KakaoLoginButton(onTap: kakaoLogin),

              const SizedBox(height: 0),
              NaverLoginButton(onTap: naverLogin),
            ],
          ),
        ),
      ),
    );
  }
}
