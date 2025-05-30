// 추후 코드 분기
/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

typedef DaySelectedCallback = void Function(
    DateTime selectedDay, DateTime focusedDay);
typedef PageChangedCallback = void Function(DateTime focusedDay);

class AnimatedCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> appointments;
  final DaySelectedCallback onDaySelected;
  final PageChangedCallback onPageChanged;

  const AnimatedCalendar({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.appointments,
    required this.onDaySelected,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedList = selectedDay != null
        ? appointments[DateTime(
        selectedDay!.year, selectedDay!.month, selectedDay!.day)] ?? []
        : [];
    final hasEvents = selectedList.isNotEmpty;
    final initialRowHeight = hasEvents ? 55.0 : 70.0;

    return Column(
      children: [
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
              focusedDay: focusedDay,
              selectedDayPredicate: (d) => isSameDay(selectedDay, d),
              onDaySelected: onDaySelected,
              onPageChanged: onPageChanged,
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
                defaultBuilder: (ctx, d, f) => _buildDayCell(
                    d, isSelected: false, isToday: false, isOutside: false),
                todayBuilder: (ctx, d, f) => _buildDayCell(
                    d, isSelected: false, isToday: true, isOutside: false),
                selectedBuilder: (ctx, d, f) => _buildDayCell(
                    d, isSelected: true, isToday: false, isOutside: false),
                outsideBuilder: (ctx, d, f) => _buildDayCell(
                    d, isSelected: false, isToday: false, isOutside: true),
                markerBuilder: (ctx, date, events) {
                  final key = DateTime(date.year, date.month, date.day);
                  if (appointments.containsKey(key) &&
                      appointments[key]!.isNotEmpty) {
                    return const Positioned(
                      bottom: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color(0xFFD9C189), shape: BoxShape.circle),
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
      ],
    );
  }

  Widget _buildDayCell(DateTime day,
      {required bool isSelected,
        required bool isToday,
        required bool isOutside}) {
    final lineColor = isSelected
        ? const Color(0xFFD9C189)
        : (isToday ? Colors.red : Colors.grey[300]!);
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
                '\${day.day}',
                style: TextStyle(
                    color: decoration != null ? Colors.white : textColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


 */