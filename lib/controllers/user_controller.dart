import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {

  // 기본 비회원
  bool _isGuest = true;

  // 사용자 정보 가져올 변수
  String _userName = '';
  String _profileImageUrl = '';

  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get profileImageUrl => _profileImageUrl;

  // 비회원 설정
  void setGuest() {
    _isGuest = true;
    _userName = '';
    _profileImageUrl = '';
    notifyListeners();
  }

  // 사용자 설정
  void setLoggedIn({required String name, required String profileUrl}) {
    _isGuest = false;
    _userName = name;
    _profileImageUrl = profileUrl;
    notifyListeners();
  }
}
