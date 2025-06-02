import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';
import 'package:fair_front/services/kakao_share_service.dart';
import 'package:fair_front/services/showup_sheet_service.dart';
import 'package:fair_front/widgets/calendar/active_calendar.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen>
    with AutomaticKeepAliveClientMixin {
  // 카카오 공유 서비스 인스턴스
  final KakaoShareService _kakaoShareService = KakaoShareService();

  // 날짜 상태 (달력 포커스용)
  DateTime _focusedDay = DateTime.now();

  // 달력에서 선택된 날짜 (선택된 날짜의 약속을 보여줄 때 씀)
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
    showAddOrEditAppointmentDialog(
      context: context,
      selectedDay: selectedDay,
      existing: existing,
      timeController: _timeController,
      locationController: _locationController,
      reloadAppointments: () async {
        await _loadAppointments();
      },
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

      // 날짜 클릭 시 콜백 : 클릭된 날짜와 포커스 날짜를 부모가 관리 ㄴ
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
