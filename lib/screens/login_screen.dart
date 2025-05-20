import 'package:flutter/material.dart';
import 'package:fair_front/widgets/logo_title.dart';
import 'package:fair_front/buttons/kakao_login_button.dart';
import 'package:fair_front/buttons/guest_login_button.dart';
import 'package:fair_front/widgets/common_appbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: common_appbar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
              const LogoTitle(),
              const SizedBox(height: 150),
              const KakaoLoginButton(),
              const GuestLoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}