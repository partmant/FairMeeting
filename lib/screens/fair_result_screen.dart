import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/controllers/map_controller.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:fair_front/models/fair_location_response.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/result_bottom_sheet.dart';
import '../screens/put_location_screen.dart';

class FairResultMapScreen extends StatefulWidget {
  final List<LatLng> coordinates;
  final LatLng center;
  final FairLocationResponse fairLocationResponse;

  const FairResultMapScreen({
    Key? key,
    required this.coordinates,
    required this.center,
    required this.fairLocationResponse,
  }) : super(key: key);

  @override
  State<FairResultMapScreen> createState() => _FairResultMapScreenState();
}

class _FairResultMapScreenState extends State<FairResultMapScreen> {
  late final MapController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  Future<void> _onMapReady(KakaoMapController mapCtrl) async {
    await _controller.onMapCreated(mapCtrl);
    for (final coord in widget.coordinates) {
      await _controller.addLocation(
        PlaceAutoCompleteResponse(
          placeName: '중간지점',
          roadAddress: '',
          latitude: coord.latitude,
          longitude: coord.longitude,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 앱바 뒤로가기와 동일한 동작: PutLocationScreen 으로 교체
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/put-location'),
            pageBuilder: (_, __, ___) => const PutLocationScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: common_appbar(context, title: '결과 화면'),
        body: Stack(
          children: [
            KakaoMap(
              option: KakaoMapOption(
                position: widget.center,
                zoomLevel: 17,
              ),
              onMapReady: _onMapReady,
            ),
            if (_loading)
              Container(
                color: Colors.white.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD9C189),
                  ),
                ),
              ),
            if (!_loading)
              FairLocationBottomSheet(
                fairLocationResponse: widget.fairLocationResponse,
              ),
          ],
        ),
      ),
    );
  }
}
