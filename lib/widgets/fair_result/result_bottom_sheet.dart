import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fair_front/buttons/put_in_calendar_button.dart';
import '../../models/fair_location_response.dart';
import 'route_list.dart';

class FairLocationBottomSheet extends StatefulWidget {
  final FairLocationResponse fairLocationResponse;

  const FairLocationBottomSheet({
    Key? key,
    required this.fairLocationResponse,
  }) : super(key: key);

  @override
  State<FairLocationBottomSheet> createState() =>
      _FairLocationBottomSheetState();
}

class _FairLocationBottomSheetState extends State<FairLocationBottomSheet> {
  late final DraggableScrollableController _sheetController;
  bool _isDraggingList = false;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();

    // 화면 렌더 후에 최대로 펼치기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.animateTo(
        _maxSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  double get _minSize {
    const headerTotalHeight = 74.0;
    final usableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom;
    return headerTotalHeight / usableHeight;
  }

  double get _maxSize {
    const handleHeight = 40.0;
    const itemH = 108.0;
    final total =
        handleHeight + widget.fairLocationResponse.routes.length * itemH;
    final usableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom;
    return min(total / usableHeight, 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final routes = widget.fairLocationResponse.routes;
    final centerName = widget.fairLocationResponse.midpointStation.name;
    final centerLat = widget.fairLocationResponse.midpointStation.latitude;
    final centerLng = widget.fairLocationResponse.midpointStation.longitude;

    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: DraggableScrollableSheet(
          expand: false,
          controller: _sheetController,
          initialChildSize: _maxSize,
          minChildSize: _minSize,
          maxChildSize: _maxSize,
          snap: true,
          snapSizes: [_minSize, _maxSize],
          builder: (context, scrollController) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  // (1) 헤더: 드래그 핸들 + 중간장소 이름
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (drag) {
                      final delta = drag.primaryDelta ?? 0;
                      final fraction = delta / MediaQuery.of(context).size.height;
                      _sheetController.jumpTo(
                        (_sheetController.size - fraction).clamp(_minSize, _maxSize),
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place, color: Colors.redAccent),
                              const SizedBox(width: 6),
                              Text(
                                centerName,
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

                  // (2) 리스트 + 버튼을 하나의 ListView 안에 묶어서 스크롤되도록 함
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification &&
                            notification.dragDetails != null) {
                          _isDraggingList = true;
                        }
                        if (notification is ScrollEndNotification) {
                          _isDraggingList = false;
                        }
                        if (notification is OverscrollNotification &&
                            notification.overscroll < 0 &&
                            notification.metrics.pixels <= 0 &&
                            _isDraggingList) {
                          _sheetController.animateTo(
                            _minSize,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: routes.length + 1, // 수정됨: 버튼까지 포함
                        itemBuilder: (context, index) {
                          if (index == routes.length) {
                            // 마지막 인덱스: PutInCalendarButton
                            return PutInCalendarButton(
                              initialLocationName: centerName,
                            );
                          }
                          final detail = routes[index];
                          return RouteListItem(
                            detail: detail,
                            centerName: centerName,
                            centerLat: centerLat,
                            centerLng: centerLng,
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
