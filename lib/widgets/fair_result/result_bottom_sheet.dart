import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/fair_location_response.dart';

class FairLocationBottomSheet extends StatefulWidget {
  final FairLocationResponse fairLocationResponse;

  const FairLocationBottomSheet({
    Key? key,
    required this.fairLocationResponse,
  }) : super(key: key);

  @override
  State<FairLocationBottomSheet> createState() => _FairLocationBottomSheetState();
}

class _FairLocationBottomSheetState extends State<FairLocationBottomSheet> {
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();

    // 화면 렌더 후에 완전 펼치기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.animateTo(
        _maxSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  double get _minSize {
    // 핸들만 보이게
    final handleHeight = 40.0;
    final screenH = MediaQuery.of(context).size.height;
    return handleHeight / screenH;
  }

  double get _maxSize {
    // 아이템 개수에 맞춰
    final handleHeight = 40.0;
    final itemH = 108.0; // 각 아이템 높이
    final total = handleHeight + widget.fairLocationResponse.routes.length * itemH;
    final screenH = MediaQuery.of(context).size.height;
    return min(total / screenH, 0.8); // 최대 80% 까지
  }

  String _formatFare(int fare) {
    // 천 단위 콤마 추가
    return fare.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = widget.fairLocationResponse.routes;

    return SafeArea(
      bottom: true,
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: _maxSize, // 처음부터 완전 펼쳐진 상태
        minChildSize: _minSize,
        maxChildSize: _maxSize,
        snap: true,
        snapSizes: [_minSize, _maxSize],
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Column(
              children: [
                // 드래그 핸들
                Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // 리스트
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      // 출발지 이름만 사용
                      final String startName = route.fromStation.name;
                      final int totalTime = route.route.totalTime; // 총 소요 분
                      final int transferCount = route.route.totalTransitCount; // 환승 횟수
                      final int walkTime = route.route.totalWalkTime; // 도보 시간(분)
                      final int fare = route.route.payment; // 비용(원)

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.directions_subway,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$startName',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 2) 소요 시간 (아이콘 없이, 텍스트만)
                              Text(
                                '총 $totalTime분',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 3) 환승 횟수 | 도보 시간 | 비용
                              Row(
                                children: [
                                  Text(
                                    '환승 ${transferCount}회',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '도보 ${walkTime}분',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_formatFare(fare)}원',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
