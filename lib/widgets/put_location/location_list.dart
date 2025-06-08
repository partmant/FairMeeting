import 'package:flutter/material.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import '../../controllers/map_controller.dart';

class LocationList extends StatelessWidget {
  final MapController controller;

  const LocationList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final List<PlaceAutoCompleteResponse> addresses = controller.selectedAddresses;

    if (addresses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: addresses.length,
        shrinkWrap: true, // 리스트 높이만큼만 차지하도록 제한
        padding: EdgeInsets.zero, // 기본 패딩 제거
        itemBuilder: (context, index) {
          final address = addresses[index];
          final String name = address.placeName;
          final double lat = address.latitude;
          final double lng = address.longitude;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              tileColor: Colors.white,
              leading: const Icon(Icons.location_on),
              title: Text(name, style: const TextStyle(fontSize: 16)),
              selected: index == controller.selectedAddressIndex,
              selectedTileColor: Colors.grey.shade200,
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  controller.deleteAddressAt(index);
                },
              ),
              onTap: () async {
                controller.selectedAddressIndex = index;
                await controller.moveCameraTo(lat, lng);
              },
            ),
          );
        },
      ),
    );
  }
}
