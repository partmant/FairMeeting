/*
Fair Meeting 로고
통일을 위해서 위젯 만듦
추후 상의 후 디자인 변경
 */

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
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9C189),
          ),
        ),
        Text(
          'MEETING',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9C189),
          ),
        ),
      ],
    );
  }
}
