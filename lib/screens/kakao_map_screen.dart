import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({super.key});

  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  KakaoMapController? mapController; // late 빼고 nullable로 수정

  @override
  void dispose() {
    mapController?.dispose(); // 컨트롤러 dispose 추가
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KakaoMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}
