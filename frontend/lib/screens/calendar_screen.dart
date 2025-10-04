import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';
import 'package:fair_front/services/kakao_share_service.dart';
import 'package:fair_front/widgets/calendar/active_calendar.dart';
import 'package:fair_front/services/showup_sheet_service.dart';

class AppointmentCalendarScreen extends StatefulWidget {

  final String? initialLocationName; // 버튼 등에서 전달해 주는 중간지점 이름(선택한 위치)
  final bool redirectToCalendar;

  const AppointmentCalendarScreen({
    Key? key,
    this.redirectToCalendar = false,
    this.initialLocationName, // 생성자에 named 파라미터로 추가
  }) : super(key: key);

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen>
    with AutomaticKeepAliveClientMixin {
  // 카카오 공유 서비스 인스턴스
  final KakaoShareService _kakaoShareService = KakaoShareService();

  // 달력 포커스용 날짜
  DateTime _focusedDay = DateTime.now();

  // 달력에서 선택된 날짜
  DateTime? _selectedDay;

  // 서버에서 불러온 약속 목록을 날짜별로 그룹핑한 맵
  final Map<DateTime, List<Map<String, dynamic>>> _appointments = {};

  // 바텀시트에 전달할 텍스트 컨트롤러
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 서버에서 약속 목록 불러와서 _appointments에 채워 넣기
  Future<void> _loadAppointments() async {
    final kakaoId =
        Provider.of<UserController>(context, listen: false).userId;
    if (kakaoId == null) return;

    try {
      final list = await AppointmentService.getAppointments(kakaoId);
      final map = <DateTime, List<Map<String, dynamic>>>{};
      for (var appt in list) {
        final key = DateTime(
          appt.date.year,
          appt.date.month,
          appt.date.day,
        );
        map.putIfAbsent(key, () => []).add({
          'id': appt.id!,
          'time': appt.time.substring(0, 5),
          'location': appt.location,
        });
      }
      setState(() {
        _appointments
          ..clear()
          ..addAll(map);
        _selectedDay ??= DateTime.now();
      });
    } catch (e) {
      debugPrint('약속 불러오기 실패: $e');
    }
  }

  // 약속 추가/수정 바텀시트 열기 콜백
  void _showAddOrEditSheet(DateTime selectedDay,
      {Map<String, dynamic>? existing}) {
    final isEditing = existing != null;

    // ——— 여기서 컨트롤러 초기화 부분 추가 ———
    // 1) 시간 컨트롤러에 기존값 또는 빈 문자열 세팅
    _timeController.text = existing?['time'] ?? '';

    // 2) 위치 컨트롤러에
    if (isEditing) {
      // 수정 모드라면 existing 데이터의 위치로 세팅
      _locationController.text = existing?['location'] ?? '';
    } else {
      // 새 약속 추가 모드
      if (widget.initialLocationName != null &&
          widget.initialLocationName!.isNotEmpty) {
        // 버튼에서 넘어와서 initialLocationName이 있다면 그것을 우선 채움
        _locationController.text = widget.initialLocationName!;
      } else {
        // 그 외엔 빈 문자열
        _locationController.clear();
      }
    }

    showAddOrEditAppointmentDialog(
      context: context,
      selectedDay: selectedDay,
      existing: existing,
      timeController: _timeController,
      locationController: _locationController,
      reloadAppointments: () async {
        await _loadAppointments();
      },
      initialLocationName: widget.initialLocationName,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AppointmentCalendarView(
      // 달력이 포커스할 날짜
      focusedDay: _focusedDay,

      // 선택된 날짜
      selectedDay: _selectedDay,

      // 서버에서 가져온 모든 약속 맵
      appointments: _appointments,

      // 페이지(월) 변경 시 콜백
      onPageChanged: (newFocusedDay) {
        setState(() {
          _focusedDay = newFocusedDay;
        });
      },

      // 날짜 클릭 시 콜백
      onDaySelected: (clickedDay, newFocusedDay) {
        setState(() {
          _selectedDay = clickedDay;
          _focusedDay = newFocusedDay;
        });
      },

      // 수정/추가 바텀시트 열기 콜백
      onShowAddOrEdit: (day, {existing}) {
        _showAddOrEditSheet(day, existing: existing);
      },

      // 약속 삭제 후 목록 다시 불러오기 콜백
      loadAppointments: () async {
        await _loadAppointments();
      },

      // 카카오톡 공유 서비스 인스턴스
      kakaoShareService: _kakaoShareService,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
