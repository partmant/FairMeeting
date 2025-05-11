import 'package:flutter/material.dart';
import 'package:fair_front/controllers/location_controller.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';

class LocationList extends StatelessWidget {
  final LocationController controller;

  const LocationList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final List<PlaceAutoCompleteResponse> addresses = controller.selectedAddresses;

    if (addresses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 150,
      child: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          final String name = address.placeName;
          final double lat = address.latitude;
          final double lng = address.longitude;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
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
                await controller.moveMapCenter(lat, lng);
              },
            ),
          );
        },
      ),
    );
  }
}
