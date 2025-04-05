import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class KakaoMapScreen extends StatefulWidget {
  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 기본 지도 생성: onMapCreated 콜백을 통해 지도 컨트롤러를 받아오기
      body: KakaoMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}
