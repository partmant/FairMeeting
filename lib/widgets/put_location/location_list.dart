import 'package:flutter/material.dart';
import 'location_button.dart';
import 'package:fair_front/controllers/map_controller.dart';

class LocationList extends StatelessWidget {
  final MapController controller;

  const LocationList({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addresses = controller.selectedAddresses;
    final canAdd = addresses.length < 5;
    final itemCount = addresses.length + (canAdd ? 1 : 0);

    return ListView.builder(
      itemCount: itemCount,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (index < addresses.length) {
          final addr = addresses[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.location_on,
                color: controller.selectedAddressIndex == index ? Colors.black : Colors.grey,
              ),
              tileColor: controller.selectedAddressIndex == index ? Colors.grey.withOpacity(0.2) : null,

              title: Text(addr.placeName),
              trailing: IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => controller.deleteAddressAt(index),
              ),
              onTap: () async {
                controller.selectedAddressIndex = index;
                await controller.moveCameraTo(addr.latitude, addr.longitude);
              },
            ),
          );
        }
        // 마지막: 위치 입력하기 버튼만
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: LocationButton(
            controller: controller,
            showReset: false,
            showAdd: true,
          ),
        );
      },
    );
  }
}

