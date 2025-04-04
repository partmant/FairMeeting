/*
아이디 찾기 ~ 비회원 로그인 버튼 위젯
각각의 버튼이 눌렸을 때는 login.dart 에서 처리 예정
 */

import 'package:flutter/material.dart';

class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const TextActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
