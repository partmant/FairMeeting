import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../widgets/common_appbar.dart';

class EditResultScreen extends StatefulWidget {
  final LatLng initialCenter; // 수정 전 원래 중간지점 좌표

  const EditResultScreen({
    Key? key,
    required this.initialCenter,
  }) : super(key: key);

  @override
  _EditResultScreenState createState() => _EditResultScreenState();
}

class _EditResultScreenState extends State<EditResultScreen> {
  late KakaoMapController _mapController;
  late LatLng _selectedCenter;  // 사용자가 마지막으로 이동시킨 지도 중심 좌표

  @override
  void initState() {
    super.initState();
    _selectedCenter = widget.initialCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: common_appbar(
        context,
        title: '중간지점 수정',
        extraActions: [
          TextButton(
            onPressed: () async {
              final shouldSubmit = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('변경 사항 저장'),
                  content: const Text('수정된 중간지점 좌표로 결과를 업데이트하시겠어요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
              // shouldSubmit가 true일 때만 pop
              if (shouldSubmit == true) {
                Navigator.of(context).pop(_selectedCenter);
              }
            },
            child: const Text(
              '완료',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          KakaoMap(
            option: KakaoMapOption(
              position: widget.initialCenter,
              zoomLevel: 17,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              // 초기 위치 바로 이동
              await controller.moveCamera(
                CameraUpdate.newCenterPosition(
                  widget.initialCenter,
                  zoomLevel: 17,
                ),
                animation: const CameraAnimation(0),
              );
            },
            onCameraMoveEnd: (CameraPosition position, GestureType _) {
              // 카메라 이동 멈춘 후 중심 좌표 업데이트
              setState(() {
                _selectedCenter = position.position;
              });
            },
            onMapError: (err) {
              debugPrint('수정 화면 지도 오류: $err');
            },
          ),
          // 화면 중앙 십자선
          const Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
