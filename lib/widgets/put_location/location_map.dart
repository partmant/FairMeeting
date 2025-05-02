import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:fair_front/controllers/location_controller.dart';

// put_location 상단의 지도
class LocationMap extends StatelessWidget {
  final LocationController controller;
  final double width;
  final double height;

  const LocationMap({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: KakaoMap(
          center: controller.currentCenter,
          markers: controller.markers.toList(),
          onMapCreated: controller.onMapCreated,

          // ✅ 지도 클릭 시 중심 이동 + 마커 이동
          onMapTap: (LatLng tappedPoint) async {
            await controller.moveMapCenter(
              tappedPoint.latitude,
              tappedPoint.longitude,
            );
            controller.moveSelectedMarker(tappedPoint);
          },

          // ✅ 사용자가 지도를 이동한 후 손을 뗐을 때 중심 좌표 갱신
          onDragChangeCallback: (latLng, zoomLevel, dragType) async {
            if (dragType == DragType.end) {
              final newCenter = await controller.mapController?.getCenter();
              if (newCenter != null) {
                controller.setMapCenter(
                  newCenter.latitude,
                  newCenter.longitude,
                );
              }
            }
          },
        ),
      ),
    );
  }
}
