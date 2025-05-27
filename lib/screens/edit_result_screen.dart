import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:provider/provider.dart';

import '../controllers/map_controller.dart';
import '../widgets/kakao_map.dart';

class EditResultScreen extends StatelessWidget {
  final LatLng initialCenter;

  const EditResultScreen({
    Key? key,
    required this.initialCenter,
  }) : super(key: key);

  void _onSubmit(BuildContext context) {
    final center = context.read<MapController>().currentCenter;
    Navigator.pop(context, center); // 수정된 중심좌표 반환
  }

  @override
  Widget build(BuildContext context) {
    // 지도를 처음 띄울 때 초기 중심 좌표 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapController>().updateCameraPosition(
        initialCenter,
        context.read<MapController>().currentZoom,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('중간지점 수정'),
        actions: [
          TextButton(
            onPressed: () => _onSubmit(context),
            child: const Text('완료', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: const KakaoMapScreen(), // 지도는 MapController를 통해 위치 제어됨
    );
  }
}
