import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class FairResultMapScreen extends StatefulWidget {
  final List<LatLng> coordinates;
  final LatLng center; // 중심 좌표 추가!

  const FairResultMapScreen({
    super.key,
    required this.coordinates,
    required this.center,
  });

  @override
  State<FairResultMapScreen> createState() => _FairResultMapScreenState();
}

class _FairResultMapScreenState extends State<FairResultMapScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공정한 만남 위치')),
      body: KakaoMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        center: widget.center, // 중심 좌표 적용
        markers: widget.coordinates
            .asMap()
            .entries
            .map((entry) => Marker(
          markerId: 'marker_${entry.key}',
          latLng: entry.value,
        ))
            .toList(),
      ),
    );
  }
}
