import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/fair_location_response.dart';
import 'package:fair_front/services/open_naver_map_service.dart';

class FairLocationBottomSheet extends StatefulWidget {
  final FairLocationResponse fairLocationResponse;

  const FairLocationBottomSheet({Key? key, required this.fairLocationResponse})
    : super(key: key);

  @override
  State<FairLocationBottomSheet> createState() =>
      _FairLocationBottomSheetState();
}

class _FairLocationBottomSheetState extends State<FairLocationBottomSheet> {
  late final DraggableScrollableController _sheetController;
  bool _isDraggingList = false; // 리스트 드래그 중인지 상태 추적

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

  // todo: 고정 픽셀 -> 비율로 수정
  double get _minSize {
    final headerTotalHeight = 74.0;
    final usableHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom;
    return headerTotalHeight / usableHeight;
  }

  double get _maxSize {
    // 아이템 개수에 맞춰 최대 높이 계산
    final handleHeight = 40.0; // 드래그 핸들 + 위쪽 여백 등 포함 대략 높이
    final itemH = 108.0; // 각 아이템 높이
    final total =
        handleHeight + widget.fairLocationResponse.routes.length * itemH;
    final usableHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom;
    return min(total / usableHeight, 0.8); // 최대 80%까지만 높이 허용
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
      top: false,
      bottom: false,
      child: SizedBox(
        // height 수정해서 아래 뜨는 거 조절 가능
        height: MediaQuery.of(context).size.height,
        child: DraggableScrollableSheet(
          expand: false,
          controller: _sheetController,
          initialChildSize: _maxSize,
          // 처음부터 완전 펼쳐진 상태
          minChildSize: _minSize,
          maxChildSize: _maxSize,
          snap: true,
          snapSizes: [_minSize, _maxSize],
          builder: (context, scrollController) {
            return Container(
              // 오버플로우 방지를 위해 clipBehavior 추가
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  // 헤더 전체(행 전체를 드래그 영역으로)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (drag) {
                      final delta = drag.primaryDelta ?? 0;
                      final fraction =
                          delta / MediaQuery.of(context).size.height;
                      _sheetController.jumpTo(
                        (_sheetController.size - fraction).clamp(
                          _minSize,
                          _maxSize,
                        ),
                      );
                    },
                    onVerticalDragEnd: (_) {
                      final mid = (_maxSize + _minSize) / 2;
                      if (_sheetController.size >= mid) {
                        _sheetController.animateTo(
                          _maxSize,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _sheetController.animateTo(
                          _minSize,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.0,
                      child: Column(
                        children: [
                          // 드래그 핸들
                          Container(
                            width: 60,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 중간지점 이름
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place, color: Colors.redAccent),
                              const SizedBox(width: 6),
                              Text(
                                widget
                                    .fairLocationResponse
                                    .midpointStation
                                    .name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 리스트 (드래그 중일 때만 시트 접기 감지)
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification &&
                            notification.dragDetails != null) {
                          // 사용자가 터치한 채로 드래그 시작
                          _isDraggingList = true;
                        }
                        if (notification is ScrollEndNotification) {
                          // 드래그 종료(관성 포함)
                          _isDraggingList = false;
                        }
                        if (notification is OverscrollNotification &&
                            notification.overscroll < 0 &&
                            notification.metrics.pixels <= 0 &&
                            _isDraggingList) {
                          // 리스트가 최상단 상태에서 사용자가 아래로 드래그할 때 시트 접기
                          _sheetController.animateTo(
                            _minSize,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                          return true;
                        }
                        return false;
                      },
                      // 여기가 객체 뜨는 곳
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 16,
                        ),
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          final route = routes[index];
                          final String startName = route.fromStation.name;
                          final String destName = widget.fairLocationResponse.midpointStation.name;
                          final int totalTime = route.route.totalTime;
                          final int transferCount =
                              route.route.totalTransitCount; // 환승 횟수
                          final int walkTime =
                              route.route.totalWalkTime; // 도보 시간(분)
                          final int fare = route.route.payment; // 비용(원)

                          // 실제 소요 시간 계산 필요

                          // 각 박스 위젯
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: InkWell(
                              onTap: () {
                                print('경로 선택: $startName → $destName');
                                final start = route.fromStation;                            // 출발 역
                                final dest  = widget.fairLocationResponse.midpointStation;  // 도착(중간) 역
                                // 네이버 지도 연결
                                openNaverWebRoute(
                                  sName: start.name,
                                  sLat: start.latitude,
                                  sLng: start.longitude,
                                  dName: dest.name,
                                  dLat: dest.latitude,
                                  dLng: dest.longitude,
                                );
                              },
                              // 잉크 리플 넣기 : 티가 안 남 (안드에서도 확인해보고 동작 안 하면 수정)
                              borderRadius: BorderRadius.circular(100),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.directions_subway,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          startName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '총 $totalTime분',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '환승 $transferCount회',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            '|',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '도보 $walkTime분',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
