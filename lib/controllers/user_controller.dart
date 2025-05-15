import 'package:flutter/material.dart';

// 비회원 여부 관리 Provider
class UserController extends ChangeNotifier {

  // 기본적으로 비회원인 상태
  bool _isGuest = true;

  bool get isGuest => _isGuest;

  // 비회원으로 설정
  void setGuest() {
    _isGuest = true;
    notifyListeners();
  }

  // 카카오 로그인 성공 시
  void setLoggedIn() {
    _isGuest = false;
    notifyListeners();
  }
}