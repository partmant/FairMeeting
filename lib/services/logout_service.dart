import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';

class LogoutService {
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '로그아웃',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  const Text('로그아웃하시겠습니까?', style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 0),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('취소', style: TextStyle(color: Colors.black)),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  final userController = context.read<UserController>();
                                  userController.setGuest();
                                  Navigator.pop(context);
                                },
                                child: const Text('확인', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
