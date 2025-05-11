import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: const AppointmentCalendarScreen(),
    );
  }
}

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState
    extends State<AppointmentCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, String>>> _appointments = {};

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _showAddAppointmentDialog(DateTime selectedDay) {
    _timeController.clear();
    _locationController.clear();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 350,
        color: Colors.white,
        child: Column(
          children: [
            const Text('새 일정 추가',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9C189),
                )),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _timeController,
              placeholder: '시간 :',
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: _locationController,
              placeholder: '장소 :',
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('취소',
                      style: TextStyle(color: Color(0xFFD9C189))),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9C189),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    child: const Text('추가',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_timeController.text.isNotEmpty &&
                          _locationController.text.isNotEmpty) {
                        final newAppointment = {
                          'time': _timeController.text,
                          'location': _locationController.text,
                        };
                        setState(() {
                          final key = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );
                          _appointments.putIfAbsent(key, () => []);
                          _appointments[key]!.add(newAppointment);
                          _selectedDay = selectedDay; // 바로 보이게
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    DateTime tempPickedDate = _focusedDay;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 350,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text('취소',
                          style: TextStyle(color: Colors.grey[900])),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('완료',
                          style: TextStyle(color: Color(0xFFD9C189))),
                      onPressed: () {
                        setState(() {
                          _focusedDay = tempPickedDate;
                          _selectedDay = tempPickedDate;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _focusedDay,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2030),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayCell(DateTime day,
      {required bool isSelected,
        required bool isToday,
        required bool isOutside}) {
    Color lineColor = isSelected
        ? Color(0xFFD9C189)
        : isToday
        ? Colors.red
        : Colors.grey[300]!;

    Color textColor; // 일요일 빨간색 글씨로 설정
    if (day.weekday == DateTime.sunday) {
      textColor = isOutside ? Colors.red[100]! : Colors.red;
    } else {
      textColor = isOutside ? Colors.grey : Colors.black;
    }

    BoxDecoration? decoration;
    if (isSelected || isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Color(0xFFD9C189) : Colors.red,
      );
    }

    return Column(    // 날짜 셀과 요일 셀 여백 제거를 위해 다시 편집
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
                  color: isSelected || isToday ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedAppointments =
    _selectedDay != null ? _getAppointmentsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.event_available, color: Colors.black),
              SizedBox(width: 8),
              Text(
                '약속 캘린더',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _showMonthYearPicker,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '${_focusedDay.year}년 ${_focusedDay.month}월',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(height: 1, color: Colors.grey[300]),
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showAddAppointmentDialog(selectedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            rowHeight: 80,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              cellMargin: EdgeInsets.zero, // 이 줄 추가
            ),
            daysOfWeekHeight: 40,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black),
              weekendStyle: TextStyle(color: Colors.grey),
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(color: Colors.black),
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final koreanWeekdays = ['일', '월', '화', '수', '목', '금', '토'];
                return Container(
                  height: 40, // 이 줄 추가
                  color: const Color(0xFFD9C189), // 요일 셀 색 변경
                  alignment: Alignment.center,
                  child: Text(
                    koreanWeekdays[day.weekday % 7],
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day,
                    isSelected: false,
                    isToday: false,
                    isOutside: false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day,
                    isSelected: false, isToday: true, isOutside: false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day,
                    isSelected: true, isToday: false, isOutside: false);
              },
              outsideBuilder: (context, day, focusedDay) {
                return _buildDayCell(day,
                    isSelected: false, isToday: false, isOutside: true);
              },
            ),
          ),
          const Divider(),
          if (selectedAppointments.isNotEmpty)
            ...selectedAppointments.asMap().entries.map((entry) {
              final index = entry.key;
              final appt = entry.value;
              return ListTile(
                title: Text('${appt['time']} - ${appt['location']}'),
                leading: const Icon(Icons.event_note),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFD9C189)),
                  onPressed: () {
                    final key = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    );
                    setState(() {
                      _appointments[key]!.removeAt(index);
                      if (_appointments[key]!.isEmpty) {
                        _appointments.remove(key);
                      }
                    });
                  },
                ),
              );
            }),
          if (_selectedDay != null && selectedAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '등록된 일정이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
