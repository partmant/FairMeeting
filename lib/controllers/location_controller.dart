import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../services/address_service.dart'; // ✅ 서비스 임포트

class LocationController {
  KakaoMapController? mapController;

  final List<Map<String, dynamic>> selectedAddresses = [];
  final Set<Marker> markers = {};
  int? selectedAddressIndex;
  LatLng currentCenter = LatLng(37.5651, 126.9784);

  VoidCallback? onChanged;

  void notify() => onChanged?.call();

  void dispose() {
    mapController?.dispose();
  }

  void onMapCreated(KakaoMapController controller) {
    mapController = controller;
    updateMapCenter(currentCenter.latitude, currentCenter.longitude);
  }

  Future<void> updateMapCenter(double lat, double lng) async {
    currentCenter = LatLng(lat, lng);
    await mapController?.panTo(currentCenter);
    notify();
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

  Future<void> moveSelectedMarker(LatLng newLatLng) async {
    if (selectedAddressIndex != null &&
        selectedAddressIndex! < selectedAddresses.length) {
      final address = selectedAddresses[selectedAddressIndex!];
      final Marker? oldMarker = address['marker'];

      if (oldMarker != null) {
        print('선택된 마커 이동 중: ${newLatLng.latitude}, ${newLatLng.longitude}');

        markers.remove(oldMarker);

        final newMarker = Marker(
          markerId: oldMarker.markerId,
          latLng: newLatLng,
          width: oldMarker.width,
          height: oldMarker.height,
          offsetX: oldMarker.offsetX,
          offsetY: oldMarker.offsetY,
        );

        address['marker'] = newMarker;
        address['lat'] = newLatLng.latitude;
        address['lng'] = newLatLng.longitude;

        markers.add(newMarker);

        // ✅ 서비스 호출로 이름 업데이트
        try {
          final name = await AddressService.fetchAddressName(
            newLatLng.latitude,
            newLatLng.longitude,
          );
          address['name'] = name;
        } catch (e) {
          print("❗ 주소명 요청 중 예외 발생: $e");
        }

        mapController?.clearMarker();
        mapController?.addMarker(markers: markers.toList());

        notify();
      }
    }
  }

  void deleteAddressAt(int index) {
    if (index >= 0 && index < selectedAddresses.length) {
      final marker = selectedAddresses[index]['marker'];
      if (marker != null) {
        markers.remove(marker);
      }

      selectedAddresses.removeAt(index);

      if (selectedAddressIndex == index) {
        selectedAddressIndex = null;
      } else if (selectedAddressIndex != null && selectedAddressIndex! > index) {
        selectedAddressIndex = selectedAddressIndex! - 1;
      }

      mapController?.clearMarker();
      mapController?.addMarker(markers: markers.toList());

      notify();
    }
  }

  void clearAll() {
    selectedAddresses.clear();
    markers.clear();
    selectedAddressIndex = null;
    mapController?.clearMarker();
    notify();
  }
}
