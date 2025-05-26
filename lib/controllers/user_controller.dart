import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {

  // 기본 비회원
  bool _isGuest = true;

  // 사용자 정보 가져올 변수
  String _userName = '';
  String _profileImageUrl = '';
  String? _userId;

  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get profileImageUrl => _profileImageUrl;
  String? get userId => _userId;

  // 비회원 설정
  void setGuest() {
    _isGuest = true;
    _userName = '';
    _profileImageUrl = '';
    _userId = null;
    notifyListeners();
  }

  // 사용자 설정
  void setLoggedIn({required String name, required String profileUrl, required String userId,}) {
    _isGuest = false;
    _userName = name;
    _profileImageUrl = profileUrl;
    _userId = userId;
    notifyListeners();
  }
}
