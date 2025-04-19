import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:fair_front/controllers/location_controller.dart';

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
          onMapTap: (LatLng tappedPoint) async {  // 지도 클릭 시
            await controller.updateMapCenter( // 지도 중심 이동
              tappedPoint.latitude,
              tappedPoint.longitude,
            );
            controller.moveSelectedMarker(tappedPoint); // 마커 이동
          },
        ),
      ),
    );
  }
}
