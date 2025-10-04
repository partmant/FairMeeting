import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fair_front/widgets/info_appbar.dart';
import 'package:fair_front/widgets/confirm_dialog.dart';
import 'package:fair_front/widgets/calendar/month_year_picker.dart';
import 'package:fair_front/widgets/calendar/share_button_row.dart';
import 'package:fair_front/screens/login_screen.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/kakao_share_service.dart';

class AppointmentCalendarView extends StatelessWidget {
  // 부모 위젯에서 넘겨줄 상태 변수들
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> appointments;

  // 부모 위젯에서 넘겨줄 콜백들
  final void Function(DateTime newFocusedDay) onPageChanged;
  final void Function(DateTime clickedDay, DateTime newFocusedDay) onDaySelected;
  final void Function(DateTime day, {Map<String, dynamic>? existing}) onShowAddOrEdit;
  final VoidCallback loadAppointments;
  final KakaoShareService kakaoShareService;

  const AppointmentCalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.appointments,
    required this.onPageChanged,
    required this.onDaySelected,
    required this.onShowAddOrEdit,
    required this.loadAppointments,
    required this.kakaoShareService,
  });

  // 날짜 셀 커스터마이징
  Widget _buildDayCell(
      DateTime day, {
        required bool isSelected,
        required bool isToday,
        required bool isOutside,
      }) {
    final lineColor = isSelected ? const Color(0xFFD9C189) : (isToday ? Colors.red : Colors.grey[300]!);
    final textColor = (day.weekday == DateTime.sunday) ? (isOutside ? Colors.red[100]! : Colors.red) : (isOutside ? Colors.grey : Colors.black);
    final decoration = (isSelected || isToday) ? BoxDecoration(
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
                style: TextStyle(
                  color: decoration != null ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 약속 정보 행
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

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜의 약속 리스트 계산
    final selectedAppointments = selectedDay != null
        ? (appointments[DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day)] ?? []) : [];

    final bool hasEvents = selectedAppointments.isNotEmpty;
    final double initialRowHeight = hasEvents ? 55 : 70;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const InfoAppBar(title: '약속 캘린더'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 다이얼
            GestureDetector(
              onTap: () {
                showMonthYearPickerSheet(
                  context: context,
                  initialDate: focusedDay,
                  onDatePicked: (picked) {
                    onDaySelected(picked, picked);
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${focusedDay.year}년 ${focusedDay.month}월',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 24, color: Colors.black),],
                ),
              ),
            ),

            // 캘린더
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
                    leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  locale: 'ko_KR',
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (sd, fd) {
                    // 부모에게 날짜 선택 이벤트 전달
                    onDaySelected(sd, fd);
                  },
                  onPageChanged: (fd) {
                    // 부모에게 페이지 변경(포커스 날짜 변경) 이벤트 전달
                    onPageChanged(fd);
                  },
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
                    defaultBuilder: (ctx, d, f) =>
                        _buildDayCell(d, isSelected: false, isToday: false, isOutside: false),
                    todayBuilder: (ctx, d, f) =>
                        _buildDayCell(d, isSelected: false, isToday: true, isOutside: false),
                    selectedBuilder: (ctx, d, f) =>
                        _buildDayCell(d, isSelected: true, isToday: false, isOutside: false),
                    outsideBuilder: (ctx, d, f) =>
                        _buildDayCell(d, isSelected: false, isToday: false, isOutside: true),
                    markerBuilder: (ctx, date, events) {
                      final key = DateTime(date.year, date.month, date.day);
                      if (appointments.containsKey(key) &&
                          appointments[key]!.isNotEmpty) {
                        return const Positioned(
                          bottom: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9C189),
                              shape: BoxShape.circle,
                            ),
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

            const Divider(),

            // 날짜 별 약속 유무에 따라 구현
            if (selectedDay != null)
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD9C189)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: selectedAppointments.isNotEmpty
                  // 약속이 있을 때 레이아웃
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoRow(
                        Icons.access_time,
                        selectedAppointments[0]['time'] as String,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.place,
                        selectedAppointments[0]['location'] as String,
                      ),
                      const SizedBox(height: 10),

                      // ShareButtonRow로 분리
                      ShareButtonRow(
                        selectedData: selectedAppointments[0],
                        selectedDay: selectedDay!,
                        onEdit: () {
                          onShowAddOrEdit(
                            selectedDay!,
                            existing: selectedAppointments[0],
                          );
                        },
                        kakaoShareService: kakaoShareService,
                      ),
                    ],
                  )
                  // “약속이 없을 때” 레이아웃
                      : Center(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final userCtrl = Provider.of<UserController>(
                            context,
                            listen: false);
                        if (userCtrl.userId == null) {
                          DialogService.showConfirmDialog(
                            context: context,
                            title: '로그인 필요',
                            message:
                            '로그인이 필요합니다.\n로그인하시겠습니까?',
                            confirmLabel: '확인',
                            onConfirm: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const LoginScreen(
                                      redirectToCalendar: true
                                    )),
                              );
                            },
                          );
                        } else {
                          onShowAddOrEdit(selectedDay!);
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              size: 20, color: Color(0xFFD9C189)),
                          SizedBox(width: 8),
                          Text(
                            '약속 추가하기',
                            style: TextStyle(
                              color: Color(0xFFD9C189),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
