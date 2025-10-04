import 'dart:async';
import 'package:flutter/material.dart';

Future<void> waitForKeyboardToDismiss(BuildContext context) async {
  final focus = FocusScope.of(context);
  if (!focus.hasPrimaryFocus && focus.hasFocus) {
    // 자판 내려가는 시간 기다림
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
