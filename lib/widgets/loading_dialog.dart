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
  Navigator.of(ctx, rootNavigator: true).pop();
}
