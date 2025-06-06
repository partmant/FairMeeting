// lib/buttons/guest_login_button.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/screens/guest_info_screen.dart';
import 'package:fair_front/screens/calendar_screen.dart';

class GuestLoginButton extends StatelessWidget {
  /// 캘린더로 복귀하려면 true
  final bool redirectToCalendar;

  /// 캘린더에 넘길 중간지점 이름
  final String? initialLocationName;

  const GuestLoginButton({
    Key? key,
    this.redirectToCalendar = false,
    this.initialLocationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('비회원 로그인 처리');

        // 상태 변경: UserController를 통해 비회원으로 설정
        context.read<UserController>().setGuest();

        if (redirectToCalendar) {
          // ─── redirected from calendar ───
          // LoginScreen 위에 올라간 뒤 다시 돌아가야 하는 캘린더 화면이
          // 네비게이션 스택에 남아 있으므로 pop()만 해 주면 됩니다.
          Navigator.of(context).pop();
        } else {
          // ─── 일반적인 비회원 로그인 흐름 ───
          // 기존처럼 GuestInfoPage로 이동합니다.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuestInfoPage()),
          );
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
            '비회원으로 계속하기',
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
