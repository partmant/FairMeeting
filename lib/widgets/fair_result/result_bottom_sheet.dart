import 'dart:math';
import 'package:fair_front/widgets/fair_result/route_list.dart';
import 'package:flutter/material.dart';
import '../../models/fair_location_response.dart';

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

  double get _minSize {
    final headerTotalHeight = 74.0;
    final usableHeight =
        MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.bottom;
    return headerTotalHeight / usableHeight;
  }

  double get _maxSize {
    final handleHeight = 40.0;
    final itemH = 108.0;
    final total =
        handleHeight + widget.fairLocationResponse.routes.length * itemH;
    final usableHeight =
        MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.bottom;
    return min(total / usableHeight, 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final routes = widget.fairLocationResponse.routes;
    final centerName = widget.fairLocationResponse.midpointStation.name;
    final centerLat  = widget.fairLocationResponse.midpointStation.latitude;
    final centerLng  = widget.fairLocationResponse.midpointStation.longitude;


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
                  // 리스트: NotificationListener로 드래그 제스처를 감지하며,
                  // 새로 만든 RouteListItem 위젯을 하나씩 렌더링
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
                          bottom: MediaQuery.of(context).padding.bottom + 16,
                        ),
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          return RouteListItem(
                            detail: routes[index],
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
