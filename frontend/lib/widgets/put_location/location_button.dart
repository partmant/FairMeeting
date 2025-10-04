import 'package:flutter/material.dart';
import 'package:fair_front/controllers/map_controller.dart';
import 'package:fair_front/screens/search_address_screen.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:dotted_border/dotted_border.dart';
import '../loading_dialog.dart';

class LocationButton extends StatelessWidget {
  final MapController controller;
  final bool showReset;
  final bool showAdd;

  const LocationButton({
    Key? key,
    required this.controller,
    this.showReset = true,
    this.showAdd = true,
  }) : super(key: key);

  Future<void> _onTap(BuildContext context) async {
    if (controller.selectedAddresses.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최대 5개까지 위치를 입력할 수 있어요.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final result = await Navigator.push<PlaceAutoCompleteResponse>(
      context,
      MaterialPageRoute(builder: (_) => const SearchAddressScreen()),
    );
    if (result != null) {
        await controller.addLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showReset)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                showLoadingDialog(context);
                try {
                  await controller.clearAll();
                } finally {
                  hideLoadingDialog(context);
                }
              },
              child: const Text(
                '초기화',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (showAdd)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: DottedBorder(
              color: Colors.black,
              strokeWidth: 1.5,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              dashPattern: const [6, 4],
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _onTap(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('위치 입력하기', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
