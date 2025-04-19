import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class LocationController {
  KakaoMapController? mapController;

  final List<Map<String, dynamic>> selectedAddresses = []; // 선택된 주소 리스트
  final Set<Marker> markers = {};
  int? selectedAddressIndex;
  LatLng currentCenter = LatLng(37.5651, 126.9784);

  VoidCallback? onChanged; // 화면 갱신을 위한 콜백

  void notify() => onChanged?.call(); // 변경된 값이 있으면 실행

  void dispose() {
    mapController?.dispose();
  }

  void onMapCreated(KakaoMapController controller) {
    // 지도 생성 시
    mapController = controller;
    updateMapCenter(
        currentCenter.latitude, currentCenter.longitude); // 현재 좌표로 지도 중심 이동
  }

  Future<void> updateMapCenter(double lat, double lng) async {
    // 지도 중심 이동 메소드
    currentCenter = LatLng(lat, lng);
    await mapController?.panTo(currentCenter); // 중심 이동
    notify(); // 위치 변경 후 UI 갱신
  }

  void addAddress(Map<String, dynamic> addressData) {
    final markerId = UniqueKey().toString();
    final lat = double.parse(addressData['lat'].toString());
    final lng = double.parse(addressData['lng'].toString());
    final position = LatLng(lat, lng);

    final marker = Marker(
      markerId: markerId,
      latLng: position,
      width: 30,
      height: 44,
      offsetX: 15,
      offsetY: 44,
    );

    addressData['marker'] = marker;
    selectedAddresses.add(addressData);
    selectedAddressIndex = selectedAddresses.length - 1;
    markers.add(marker);

    mapController?.addMarker(markers: markers.toList());
    notify();
  }

  void moveSelectedMarker(LatLng newLatLng) {
    if (selectedAddressIndex != null &&
        selectedAddressIndex! < selectedAddresses.length) {
      final address = selectedAddresses[selectedAddressIndex!];
      final Marker? oldMarker = address['marker'];

      if (oldMarker != null) {
        print('선택된 마커 이동 중: ${newLatLng.latitude}, ${newLatLng.longitude}');  // 확인용 출력문

        // 기존 마커 제거: 메모리와 리스트에서 제거
        markers.remove(oldMarker);

        // 새 마커 생성
        final newMarker = Marker(
          markerId: oldMarker.markerId,
          // 같은 ID 유지
          latLng: newLatLng,
          width: oldMarker.width,
          height: oldMarker.height,
          offsetX: oldMarker.offsetX,
          offsetY: oldMarker.offsetY,
        );

        // 리스트, 맵에 반영
        address['marker'] = newMarker;
        address['lat'] = newLatLng.latitude;
        address['lng'] = newLatLng.longitude;

        markers.add(newMarker); 

        // 모든 마커 제거 후 다시 추가
        mapController?.clearMarker();
        mapController?.addMarker(markers: markers.toList());

        notify();
      }
    }
  }

  void deleteAddressAt(int index) { // 선택된 주소 삭제
    if (index >= 0 && index < selectedAddresses.length) {
      final marker = selectedAddresses[index]['marker'];
      if (marker != null) {
        markers.remove(marker);
      }

      selectedAddresses.removeAt(index);

      if (selectedAddressIndex == index) {
        selectedAddressIndex = null;
      } else
      if (selectedAddressIndex != null && selectedAddressIndex! > index) {
        selectedAddressIndex = selectedAddressIndex! - 1;
      }

      notify();
    }
  }

  void clearAll() {
    selectedAddresses.clear();
    markers.clear();
    selectedAddressIndex = null;
    notify();
  }
}
