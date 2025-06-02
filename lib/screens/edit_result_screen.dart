import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../widgets/common_appbar.dart';
import '../widgets/dialog_widget.dart';

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
            onPressed: () {
              DialogService.showConfirmDialog(
                context: context,
                title: '변경 사항 저장',
                message: '중간지점을 수정하시겠습니까?',
                cancelLabel: '취소',
                confirmLabel: '확인',
                onConfirm: () {
                  Navigator.of(context).pop(_selectedCenter);
                },
              );
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
              // 초기 위치 바로 이동 (애니메이션 없이)
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
          // 화면 중앙 십자선 (가로)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 2,
                color: Colors.redAccent.withOpacity(0.5),
              ),
            ),
          ),
          // 화면 중앙 십자선 (세로)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 2,
                color: Colors.redAccent.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
