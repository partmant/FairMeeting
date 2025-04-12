import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:fair_front/widgets/go_back.dart';
import 'package:fair_front/screens/search_address_screen.dart';
import 'package:dotted_border/dotted_border.dart'; // 점선 테두리용

class PutLocationScreen extends StatefulWidget {
  const PutLocationScreen({super.key});

  @override
  State<PutLocationScreen> createState() => _PutLocationScreenState();
}

class _PutLocationScreenState extends State<PutLocationScreen> {
  KakaoMapController? mapController;

  // 선택된 주소 정보(Map: 'name', 'lat', 'lng', 'markerId')를 저장할 리스트
  List<Map<String, dynamic>> _selectedAddresses = [];

  // 지도에 표시할 마커들을 관리하는 Set
  Set<Marker> _markers = {};

  // 지도 중심 좌표 (상태 변수)
  LatLng _currentCenter = LatLng(37.5651, 126.9784);

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  // 지도 생성 시 호출되는 콜백, 초기 마커와 지도 중심을 설정
  void _onMapCreated(KakaoMapController controller) {
    mapController = controller;
    _updateMapCenter(
      lat: _currentCenter.latitude,
      lng: _currentCenter.longitude,
    );
  }

  // _updateMapCenter: 새 좌표로 상태 업데이트 후, panTo()로 카메라 이동(애니메이션 효과)
  Future<void> _updateMapCenter({required double lat, required double lng}) async {
    final newCenter = LatLng(lat, lng);
    setState(() {
      _currentCenter = newCenter;
    });
    // 카메라 이동: panTo()를 호출하여 애니메이션 효과로 새로운 중심으로 이동
    mapController?.panTo(newCenter);
  }

  // 새로운 주소에 대한 마커를 추가하는 함수. addressData에 markerId를 삽입합니다.
  void _addMarkerForAddress(Map<String, dynamic> addressData) {
    final String markerId = UniqueKey().toString();
    addressData['markerId'] = markerId;
    final LatLng markerPosition = LatLng(
      double.parse(addressData['lat'].toString()),
      double.parse(addressData['lng'].toString()),
    );
    setState(() {
      _markers.add(Marker(
        markerId: markerId,
        latLng: markerPosition,
      ));
    });
  }

  // "위치 입력하기" 버튼을 눌러 SearchAddressScreen으로 이동 후 선택한 주소 처리
  void _navigateToSearchAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchAddressScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedAddresses.add(result);
      });
      _addMarkerForAddress(result);
      await _updateMapCenter(
        lat: double.parse(result['lat'].toString()),
        lng: double.parse(result['lng'].toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double mapWidth = MediaQuery.of(context).size.width - 20; // 좌우 여백 10씩
    const double sidePadding = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildCommonAppBar(context, title: '위치 입력하기'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: sidePadding),
            // 지도 영역 (KakaoMap 위젯에 _currentCenter와 누적된 _markers 전달)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: sidePadding),
              width: double.infinity,
              height: mapWidth, // 1:1 비율
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: KakaoMap(
                  center: _currentCenter,
                  markers: _markers.toList(),
                  onMapCreated: _onMapCreated,
                ),
              ),
            ),
            const SizedBox(height: sidePadding),
            // 전체 삭제 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    print('전체 삭제 버튼 클릭됨');
                    setState(() {
                      _selectedAddresses.clear();
                      _markers.clear();
                    });
                  },
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: sidePadding),
            // 위치 입력하기 버튼 (점선 테두리)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: sidePadding),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DottedBorder(
                color: Colors.black,
                strokeWidth: 1.5,
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [6, 4],
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _navigateToSearchAddress,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '위치 입력하기',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 선택된 주소들을 스크롤 가능한 리스트로 표시 (삭제 및 지도 이동 지원)
            if (_selectedAddresses.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: sidePadding),
                height: 150,
                child: ListView.builder(
                  itemCount: _selectedAddresses.length,
                  itemBuilder: (context, index) {
                    final addressData = _selectedAddresses[index];
                    final String name = addressData['name'] ?? '';
                    final double lat = double.parse(addressData['lat'].toString());
                    final double lng = double.parse(addressData['lng'].toString());
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(name, style: const TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            String? markerId = addressData['markerId'];
                            if (markerId != null) {
                              setState(() {
                                _markers.removeWhere((marker) => marker.markerId == markerId);
                                _selectedAddresses.removeAt(index);
                              });
                            }
                          },
                        ),
                        onTap: () async {
                          // 선택된 주소 항목 탭 시, 지도 중심 및 마커 업데이트 (기존 항목은 그대로 남음)
                          await _updateMapCenter(lat: lat, lng: lng);
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 100), // 하단 버튼 공간 확보
          ],
        ),
      ),
      // 하단 고정 "Fair Meeting !" 버튼
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              child: Divider(
                color: Colors.black26,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding, vertical: sidePadding),
              child: OutlinedButton(
                onPressed: () {
                  print('모임 장소 확정 버튼 눌림');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD9C189), width: 2),
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFFD9C189),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Fair Meeting !',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
