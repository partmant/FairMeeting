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
    final itemH = 72.0;
    final total = handleHeight + widget.fairLocationResponse.routes.length * itemH;
    final screenH = MediaQuery.of(context).size.height;
    return min(total / screenH, 0.8); // 최대 80% 까지
  }

  @override
  Widget build(BuildContext context) {
    final routes = widget.fairLocationResponse.routes;

    return SafeArea(
      bottom: true,
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: _maxSize,    // 처음부터 완전 펼쳐진 상태
        minChildSize: _minSize,        // 핸들만 보이기
        maxChildSize: _maxSize,        // 다시는 이 이상 안 올라가게
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
                      return ListTile(
                        leading: const Icon(Icons.directions_transit),
                        title: Text('출발지: ${route.fromStation.name}'),
                        subtitle: Text('중간지점까지: ${route.route.totalTime}분'),
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
