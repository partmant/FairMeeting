import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrightnessSettingsPage extends StatefulWidget {
  const BrightnessSettingsPage({Key? key}) : super(key: key);

  @override
  State<BrightnessSettingsPage> createState() => _BrightnessSettingsPageState();
}

class _BrightnessSettingsPageState extends State<BrightnessSettingsPage> {
  double _brightness = 0.5;
  bool _autoBrightness = false;
  bool _batterySaver = false;
  bool _nightMode = false;
  bool _darkMode = false;

  static const platform = MethodChannel('brightness_channel');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _brightness = prefs.getDouble('brightness') ?? 0.5;
      _autoBrightness = prefs.getBool('autoBrightness') ?? false;
      _batterySaver = prefs.getBool('batterySaver') ?? false;
      _nightMode = prefs.getBool('nightMode') ?? false;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('brightness', _brightness);
    await prefs.setBool('autoBrightness', _autoBrightness);
    await prefs.setBool('batterySaver', _batterySaver);
    await prefs.setBool('nightMode', _nightMode);
    await prefs.setBool('darkMode', _darkMode);
  }

  Future<bool> _checkWriteSettingsPermission() async {
    try {
      final result = await platform.invokeMethod<bool>('checkWriteSettings');
      return result ?? false;
    } catch (e) {
      print("권한 확인 오류: $e");
      return false;
    }
  }

  Future<void> _requestWriteSettingsPermission() async {
    try {
      await platform.invokeMethod('requestWriteSettings');
    } catch (e) {
      print("권한 요청 오류: $e");
    }
  }

  Future<void> _setBrightness(double value) async {
    final hasPermission = await _checkWriteSettingsPermission();
    if (!hasPermission) {
      await _requestWriteSettingsPermission();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("밝기 설정 권한이 필요합니다.")),
      );
      return;
    }

    try {
      await ScreenBrightness().setScreenBrightness(value);
      await _saveSettings(); // 저장
    } catch (e) {
      print("밝기 설정 오류: $e");
    }
  }

  void _showBrightnessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFFDF6E3),
              title: const Text(
                "화면 밝기 조절",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.brightness_6, size: 36, color: Colors.black87),
                  const SizedBox(height: 15),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.brown[400],
                      inactiveTrackColor: Colors.orange[100],
                      thumbColor: Colors.brown,
                      overlayColor: Colors.orange.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _brightness,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() => _brightness = value);
                        setStateInDialog(() {});
                        _setBrightness(value);
                      },
                    ),
                  ),
                  Text(
                    '${(_brightness * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: Colors.black87)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget buildSectionTitle(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CupertinoSwitch(
            value: value,
            onChanged: (val) {
              onChanged(val);
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(height: 13, thickness: 1.1, color: Color(0xFFD9C189));
  }

  Widget buildBrightnessControlTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: InkWell(
        onTap: _showBrightnessDialog,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("화면 밝기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.brightness_6, color: Colors.black, size: 35),
              SizedBox(width: 8),
              Text(
                '화면',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          buildBrightnessControlTile(),
          const SizedBox(height: 15),
          buildDivider(),
          buildSectionTitle("자동 밝기", _autoBrightness, (value) {
            setState(() => _autoBrightness = value);
          }),
          buildDivider(),
          buildSectionTitle("배터리 절약 모드", _batterySaver, (value) {
            setState(() => _batterySaver = value);
          }),
          buildDivider(),
          buildSectionTitle("야간 모드", _nightMode, (value) {
            setState(() => _nightMode = value);
          }),
          buildDivider(),
          buildSectionTitle("다크 모드", _darkMode, (value) {
            setState(() => _darkMode = value);
          }),
          buildDivider(),
        ],
      ),
    );
  }
}
