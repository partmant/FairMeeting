import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState
    extends State<AppointmentCalendarScreen> {
  DateTime _focusedDay = DateTime(2025, 3, 27);
  DateTime? _selectedDay;

  final List<int> _yearList = [for (var y = 2023; y <= 2030; y++) y];
  int _selectedYear = 2025;
  int _selectedMonth = 3;

  List<DateTime> markedDates = [
    DateTime(2025, 3, 9),
    DateTime(2025, 3, 22),
    DateTime(2025, 3, 27),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 뒤로가기 버튼
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // 제목
            Transform.translate(
              offset: const Offset(0, -15),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.event_note_outlined, size: 28),
                    SizedBox(width: 8),
                    Text(
                      '약속 캘린더',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 드롭다운
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<int>(
                    value: _selectedYear,
                    items: _yearList.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year년'),
                      );
                    }).toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() {
                          _selectedYear = year;
                          _focusedDay =
                              DateTime(_selectedYear, _selectedMonth, 1);
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedMonth,
                    items: List.generate(12, (i) => i + 1).map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text('$month월'),
                      );
                    }).toList(),
                    onChanged: (month) {
                      if (month != null) {
                        setState(() {
                          _selectedMonth = month;
                          _focusedDay =
                              DateTime(_selectedYear, _selectedMonth, 1);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 캘린더 (비율 줄이기)
            Transform.scale(
              scale: 0.8, // 전체 비율 축소
              child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedYear = focusedDay.year;
                    _selectedMonth = focusedDay.month;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedYear = focusedDay.year;
                    _selectedMonth = focusedDay.month;
                  });
                },
                headerVisible: false,
                daysOfWeekHeight: 40,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  todayDecoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final text = DateFormat.E('ko_KR').format(day);
                    final isWeekend = day.weekday == DateTime.sunday ||
                        day.weekday == DateTime.saturday;

                    BorderRadius borderRadius = BorderRadius.zero;
                    if (day.weekday == DateTime.sunday) {
                      borderRadius =
                      const BorderRadius.only(topLeft: Radius.circular(12));
                    } else if (day.weekday == DateTime.saturday) {
                      borderRadius = const BorderRadius.only(
                          topRight: Radius.circular(12));
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5D597),
                        border: Border.all(
                            color: const Color(0xFFCCCCCC), width: 0.5),
                        borderRadius: borderRadius,
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isWeekend ? Colors.red : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildDayCell(day, false);
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return _buildDayCell(day, true);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('y년 M월 d일').format(_selectedDay!) +
                                '\n시간 : ',
                            style: const TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: Colors.black), // ← 글자 색 변경
                            child: const Text('알림 끄기'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '장소 :',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '주소 :',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: Colors.black), // ← 글자 색 변경
                            child: const Text('+ 메모 추가하기'),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: Colors.black), // ← 글자 색 변경
                            child: const Text('길찾기'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isOutside) {
    bool isLastWeek = day
        .isAfter(DateTime(_focusedDay.year, _focusedDay.month + 1, 0)
        .subtract(const Duration(days: 7)));

    BorderRadius borderRadius = BorderRadius.zero;
    if (isLastWeek && day.weekday == DateTime.saturday) {
      borderRadius = const BorderRadius.only(
        bottomRight: Radius.circular(12),
      );
    } else if (isLastWeek && day.weekday == DateTime.sunday) {
      borderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(12),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: const Border(
          right: BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isOutside ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}