import 'package:fair_front/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'screens/login.dart';
import 'screens/app_start.dart';
import 'screens/kakao_map_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '9255023b3d9eebeecb1887c7ec03991d'
  );
  AuthRepository.initialize(appKey: '37a305a2cced0d6cc202933800e44385');  // 앱 실행 전에 반드시 카카오 지도 플러그인 초기화

  runApp(const FairMeetingApp());
}

class FairMeetingApp extends StatelessWidget {
  const FairMeetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fair Meeting',
      debugShowCheckedModeBanner: false,  //디버그 배너 제거

      home: const AppStart(),  // 로그인 화면을 호출

      //home: KakaoMapScreen(),

      routes: {
        '/main' : (context) => MainmenuScreen()
      },
    );
  }
}
