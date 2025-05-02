import 'package:flutter/material.dart';
import 'package:fair_front/controllers/location_controller.dart';

class LocationList extends StatelessWidget {
  final LocationController controller;

  const LocationList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final addresses = controller.selectedAddresses;

    if (addresses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 150,
      child: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          final String name = address['name'] ?? '';
          final double lat = double.parse(address['lat'].toString());
          final double lng = double.parse(address['lng'].toString());

          return Card(  // 주소 리스트 카드 위젯으로
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(name, style: const TextStyle(fontSize: 16)),
              selected: index == controller.selectedAddressIndex, // 선택된 주소 강조
              selectedTileColor: Colors.grey.shade200,
              trailing: IconButton( // 주소 삭제 버튼
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  controller.deleteAddressAt(index);
                },
              ),
              onTap: () async { // 주소 클릭 시 해당 주소로 지도 중심 이동
                controller.selectedAddressIndex = index;
                await controller.moveMapCenter(lat, lng); // 수정된 메서드 사용
              },
            ),
          );
        },
      ),
    );
  }
}
