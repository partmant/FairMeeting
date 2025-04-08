import 'package:fair_front/screens/auto_address_complete_screen.dart';
import 'package:fair_front/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'screens/login.dart';
import 'screens/loading_screen.dart';
import 'screens/kakao_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '9255023b3d9eebeecb1887c7ec03991d',
  );
  AuthRepository.initialize(
    appKey: '37a305a2cced0d6cc202933800e44385',
  ); // 카카오 지도 플러그인 초기화

  // 상태바 스타일을 앱 전역으로 설정 (검정색 아이콘)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark, // Android
    statusBarBrightness: Brightness.light, // iOS
  ));

  runApp(const FairMeetingApp());
}

class FairMeetingApp extends StatelessWidget {
  const FairMeetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fair Meeting',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark, // Android
            statusBarBrightness: Brightness.light, // iOS
          ),
        ),
      ),

      home: const AppStart(), // 초기 화면 (로그인 등)

      routes: {
        '/main': (context) => MainmenuScreen(),
        '/map': (context) => const KakaoMapScreen(),
      },
    );
  }
}
