import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext ctx) {
  showDialog(
    context: ctx,
    barrierDismissible: false,
    barrierColor: Colors.white.withOpacity(0.5),
    useRootNavigator: true,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFD9C189),
      ),
    ),
  );
}

void hideLoadingDialog(BuildContext ctx) {
  try {
    Navigator.of(ctx, rootNavigator: true).pop();
  } catch (_) {
    // 팝할 다이얼로그가 없을 경우 예외가 발생할 수 있으므로 무시
  }
}
