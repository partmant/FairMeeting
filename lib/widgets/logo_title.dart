import 'package:flutter/material.dart';

class LogoTitle extends StatelessWidget {
  const LogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'FAIR',
          style: TextStyle(
            fontFamily: 'Itim', // 폰트 수정
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9C189),
          ),
        ),
        Text(
          'MEETING',
          style: TextStyle(
            fontFamily: 'Itim', // 폰트 수정
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9C189),
          ),
        ),
      ],
    );
  }
}
