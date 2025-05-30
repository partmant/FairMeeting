import 'package:flutter/material.dart';

typedef ConfirmCallback = void Function();

class DialogService {
  // 확인/취소 버튼이 있는 커스텀 다이얼로그
  static void showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = '취소',
    String confirmLabel = '확인',
    Color confirmColor = Colors.black,
    ConfirmCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(message, style: const TextStyle(color: Colors.black)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(cancelLabel, style: const TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 24),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          if (onConfirm != null) onConfirm();
                        },
                        child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
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
