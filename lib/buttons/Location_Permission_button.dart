import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPermissionSettingsPage extends StatefulWidget {
  @override
  _LocationPermissionSettingsPageState createState() =>
      _LocationPermissionSettingsPageState();
}

class _LocationPermissionSettingsPageState
    extends State<LocationPermissionSettingsPage> {
  String _selectedOption = '앱 사용 중에만 허용';
  bool _isPreciseLocationEnabled = false; // 정확한 위치 사용 여부 저장

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  // 저장된 설정 불러오기
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption = prefs.getString('location_option') ?? '앱 사용 중에만 허용';
      _isPreciseLocationEnabled = prefs.getBool('precise_location') ?? false;
    });
  }
  // SharedPreferences에 설정된 값 저장
  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('location_option', _selectedOption);
    await prefs.setBool('precise_location', _isPreciseLocationEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 25), // 설정 아이콘 + 텍스트 상하 위치 조정
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings,
                color: Colors.black,
                size: 28, // 아이콘 크기
              ),
              SizedBox(width: 8),
              Text(
                '설정   ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25, // 텍스트 크기
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Text(
              '이 앱의 위치 액세스 권한',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            _buildRadioOption('항상 허용'),
            _buildRadioOption('앱 사용 중에만 허용'),
            _buildRadioOption('허용 안함'),
            SizedBox(height: 12),
            Divider(thickness: 1),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '정확한 위치 사용',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '정확한 위치가 사용 중지된 경우 앱이\n대략적인 위치 정보에 액세스할 수 있습니다',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _isPreciseLocationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isPreciseLocationEnabled = value;
                    });
                    _savePreferences(); // 설정 저장
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // 위치 권한 옵션을 위한 라디오 버튼 위젯 생성
  Widget _buildRadioOption(String text) {
    return RadioListTile<String>(
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: text,
      groupValue: _selectedOption,
      activeColor: Color(0xFFD9C189),
      onChanged: (value) {
        setState(() {
          _selectedOption = value!;
        });
        _savePreferences();
        _handlePermissionChange(value!);// 권한 변경 처리
      },
    );
  }
  // 권한 요청 또는 앱 설정 화면 이동 처리
  Future<void> _handlePermissionChange(String option) async {
    if (option == '항상 허용') {
      await Permission.locationAlways.request();
    } else if (option == '앱 사용 중에만 허용') {
      await Permission.locationWhenInUse.request();
    } else if (option == '허용 안함') {
      openAppSettings();
    }
  }
}
