import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class FairResultMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const FairResultMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<FairResultMapScreen> createState() => _FairResultMapScreenState();
}

class _FairResultMapScreenState extends State<FairResultMapScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    final LatLng center = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('공정한 만남 위치')),
      body: KakaoMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: [
          Marker(
            markerId: UniqueKey().toString(),
            latLng: center,
            // InfoWindow 없이 단순 마커만 표시
          ),
        ],
        center: center,
      ),
    );
  }
}
