import 'package:flutter/material.dart';
import 'package:fair_front/screens/calendar_screen.dart';
import 'package:fair_front/widgets/confirm_dialog.dart';
import 'package:fair_front/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class PutInCalendarButton extends StatelessWidget {
  final String initialLocationName;
  final VoidCallback? onPressed;

  const PutInCalendarButton({
    Key? key,
    required this.initialLocationName,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            final userId =
                Provider.of<UserController>(context, listen: false).userId;
            if (userId == null) {
              // 비회원일 때: 로그인 확인 다이얼로그 띄우기
              DialogService.showConfirmDialog(
                context: context,
                title: '로그인 필요',
                message: '로그인이 필요합니다.\n로그인하시겠습니까?',
                confirmLabel: '확인',
                onConfirm: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => LoginScreen(
                            redirectToCalendar: true,
                            initialLocationName: initialLocationName,
                          ),
                    ),
                  );
                },
                cancelLabel: '취소',
              );
              return;
            } else {
              // 이미 로그인된 상태면, 바로 캘린더 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AppointmentCalendarScreen(
                        initialLocationName: initialLocationName,
                      ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFD9C189),
            side: const BorderSide(color: Color(0xFFD9C189), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('캘린더에 등록하기'),
        ),
      ),
    );
  }
}
