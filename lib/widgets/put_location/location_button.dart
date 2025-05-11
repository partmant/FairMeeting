import 'package:flutter/material.dart';
import 'package:fair_front/controllers/location_controller.dart';
import 'package:fair_front/screens/search_address_screen.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:dotted_border/dotted_border.dart';

class LocationButton extends StatelessWidget {
  final LocationController controller;

  const LocationButton({super.key, required this.controller});

  void _navigateToSearchAddress(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchAddressScreen()),
    );

    if (result != null && result is PlaceAutoCompleteResponse) {
      controller.addAddress(result);
      await controller.moveMapCenter(
        result.latitude,
        result.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => controller.clearAll(),
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
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
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
                onPressed: () => _navigateToSearchAddress(context),
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
      ],
    );
  }
}
