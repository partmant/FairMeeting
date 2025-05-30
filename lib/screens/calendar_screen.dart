import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fair_front/widgets/info_appbar.dart';
import 'package:fair_front/widgets/add_calendar_sheet.dart';
import 'package:fair_front/widgets/month_year_picker.dart';
import 'package:fair_front/widgets/dialog_widget.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';
import 'package:fair_front/screens/login_screen.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() => _AppointmentCalendarScreenState();
}

// 상태 정의
class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // 약속 목록 불러오기
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // 서버에서 데이터 불러와서 날짜 별로 그룹핑
  Future<void> _loadAppointments() async {
    final kakaoId = Provider.of<UserController>(context, listen: false).userId;
    if (kakaoId == null) return;
    try {
      final list = await AppointmentService.getAppointments(kakaoId);
      final map = <DateTime, List<Map<String, dynamic>>>{};
      for (var appt in list) {
        final key = DateTime(appt.date.year, appt.date.month, appt.date.day);
        map.putIfAbsent(key, () => []).add({
          'id': appt.id!,
          'time': appt.time.substring(0, 5),
          'location': appt.location,
        });
      }
      setState(() {
        _appointments..clear()..addAll(map);
        _selectedDay ??= DateTime.now();
      });
    } catch (e) {
      debugPrint('약속 불러오기 실패: $e');
    }
  }

  // 약속 추가/수정 바텀 시트 호출
  void _showAddOrEditSheet(DateTime selectedDay, {Map<String, dynamic>? existing, VoidCallback? onDelete}) {
    _timeController.text = existing?['time'] ?? '';
    _locationController.text = existing?['location'] ?? '';
    final isEditing = existing != null;

    showAddAppointmentSheet(
      context: context,
      timeController: _timeController,
      locationController: _locationController,
      title: isEditing ? '약속 수정하기' : '새 약속 추가',
      isEditing: isEditing,
      onCancel: () => Navigator.of(context).pop(),
      onAdd: () async {
        if (_timeController.text.isEmpty || _locationController.text.isEmpty) return;
        final kakaoId = Provider.of<UserController>(context, listen: false).userId!;
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
        final timeStr = _timeController.text;
        final location = _locationController.text;
        try {
          if (isEditing) {
            await AppointmentService.updateAppointment(
              id: existing!['id'] as int,
              kakaoId: kakaoId,
              date: dateStr,
              time: timeStr,
              location: location,
            );
          } else {
            await AppointmentService.createAppointment(
              kakaoId: kakaoId,
              date: dateStr,
              time: timeStr,
              location: location,
            );
          }
          await _loadAppointments();
          Navigator.of(context).pop();
        } catch (e) {
          final msg = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      onDelete: onDelete,
    );
  }

  // 날짜 셀 커스터마이징
  Widget _buildDayCell(DateTime day, {required bool isSelected, required bool isToday, required bool isOutside}) {
    final lineColor = isSelected ? const Color(0xFFD9C189) : (isToday ? Colors.red : Colors.grey[300]!);
    final textColor = (day.weekday == DateTime.sunday)
        ? (isOutside ? Colors.red[100]! : Colors.red)
        : (isOutside ? Colors.grey : Colors.black);
    final decoration = (isSelected || isToday)
        ? BoxDecoration(
      shape: BoxShape.circle,
      color: isSelected ? const Color(0xFFD9C189) : Colors.red,
    )
        : null;

    return Column(
      children: [
        Container(height: 1, color: lineColor),
        Expanded(
          child: Center(
            child: Container(
              decoration: decoration,
              padding: const EdgeInsets.all(8),
              child: Text(
                '${day.day}',
                style: TextStyle(color: decoration != null ? Colors.white : textColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 캘린더 및 날짜별 약속 UI 구성
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final selectedAppointments = _selectedDay != null
        ? _appointments[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []
        : [];

    final bool hasEvents = selectedAppointments.isNotEmpty;
    final double initialRowHeight = hasEvents ? 55 : 70;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const InfoAppBar(title: '약속 캘린더'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 월/년 선택 영역
            GestureDetector(
              onTap: () => showMonthYearPickerSheet(
                context: context,
                initialDate: _focusedDay,
                onDatePicked: (picked) => setState(() {
                  _focusedDay = picked;
                  _selectedDay = picked;
                }),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_focusedDay.year}년 ${_focusedDay.month}월', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 24, color: Colors.black),
                  ],
                ),
              ),
            ),

            // 캘린더 위젯
            Container(height: 1, color: Colors.grey[300]),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: initialRowHeight, end: initialRowHeight),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, rowH, _) {
                return TableCalendar(
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.black),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  locale: 'ko_KR',
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (sd, fd) => setState(() {
                    _selectedDay = sd;
                    _focusedDay = fd;
                  }),
                  onPageChanged: (fd) => setState(() => _focusedDay = fd),
                  rowHeight: rowH,
                  calendarStyle: const CalendarStyle(
                    cellMargin: EdgeInsets.zero,
                    markersMaxCount: 1,
                    markersAlignment: Alignment.bottomCenter,
                  ),
                  daysOfWeekHeight: 40,
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (ctx, day) {
                      const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                      return Container(
                        height: 40,
                        color: const Color(0xFFD9C189),
                        alignment: Alignment.center,
                        child: Text(
                          weekdays[day.weekday % 7],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    defaultBuilder: (ctx, d, f) => _buildDayCell(d, isSelected: false, isToday: false, isOutside: false),
                    todayBuilder: (ctx, d, f) => _buildDayCell(d, isSelected: false, isToday: true, isOutside: false),
                    selectedBuilder: (ctx, d, f) => _buildDayCell(d, isSelected: true, isToday: false, isOutside: false),
                    outsideBuilder: (ctx, d, f) => _buildDayCell(d, isSelected: false, isToday: false, isOutside: true),
                    markerBuilder: (ctx, date, events) {
                      final key = DateTime(date.year, date.month, date.day);
                      if (_appointments.containsKey(key) && _appointments[key]!.isNotEmpty) {
                        return const Positioned(
                          bottom: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFD9C189), shape: BoxShape.circle),
                            child: SizedBox(width: 6, height: 6),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
            // 날짜에 따라 약속 정보 등 표시
            const Divider(),
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD9C189)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (selectedAppointments.isNotEmpty) ...[
                        _buildInfoRow(Icons.access_time, selectedAppointments[0]['time'] as String),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.place, selectedAppointments[0]['location'] as String),
                        const SizedBox(height: 10),
                        // 수정 및 공유 버튼
                        Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text('수정', style: TextStyle(color: Color(0xFFD9C189))),
                              onPressed: () => _showAddOrEditSheet(
                                _selectedDay!,
                                existing: selectedAppointments[0],
                                onDelete: () async {
                                  final id = selectedAppointments[0]['id'] as int;
                                  final kakaoId = Provider.of<UserController>(context, listen: false).userId!;
                                  await AppointmentService.deleteAppointment(id: id, kakaoId: kakaoId);
                                  await _loadAppointments();
                                },
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(color: const Color(0xFFD9C189), borderRadius: BorderRadius.circular(8)),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                onPressed: () {
                                  final location = selectedAppointments[0]['location'] as String;
                                  final time = selectedAppointments[0]['time'] as String;
                                  final date = DateFormat('yyyy.MM.dd').format(_selectedDay!);
                                  final text = '[FairMeeting] 약속이 있어요!\n\n📍 장소: $location\n⏰ 시간: $date $time';
                                  // TODO: 카카오톡 공유 연동 처리
                                },
                                child: const Text('공유', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Center(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              final userCtrl = Provider.of<UserController>(context, listen: false);
                              if (userCtrl.userId == null) {
                                DialogService.showConfirmDialog(
                                  context: context,
                                  title: '로그인 필요',
                                  message: '로그인이 필요합니다.\n로그인하시겠습니까?',
                                  confirmLabel: '확인',
                                  onConfirm: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                );
                              } else {
                                _showAddOrEditSheet(_selectedDay!);
                              }
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 20, color: Color(0xFFD9C189)),
                                SizedBox(width: 8),
                                Text('약속 추가하기', style: TextStyle(color: Color(0xFFD9C189), fontSize: 20, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 상태 유지 설정
  @override
  bool get wantKeepAlive => true;

  // 약속 정보 표시용 UI 행
  Widget _buildInfoRow(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFD9C189)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD9C189)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}
