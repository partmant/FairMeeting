import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';

class LogoutService {
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('로그아웃', style: TextStyle(color: Colors.black)),
          content: const Text('로그아웃하시겠습니까?', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: const Text('취소', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                final userController = context.read<UserController>();
                userController.setGuest();
                Navigator.pop(context); // 이전 화면으로
              },
            ),
          ],
        );
      },
    );
  }
}
