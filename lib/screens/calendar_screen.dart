import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fair_front/widgets/info_appbar.dart';
import 'package:fair_front/widgets/add_calendar_sheet.dart';
import 'package:fair_front/widgets/month_year_picker.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() => _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, String>>> _appointments = {};
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _showAddOrEditSheet(DateTime selectedDay, {Map<String, String>? existing}) {
    _timeController.text = existing?['time'] ?? '';
    _locationController.text = existing?['location'] ?? '';

    final isEditing = existing != null;

    showAddAppointmentSheet(
      context: context,
      timeController: _timeController,
      locationController: _locationController,
      onCancel: () => Navigator.of(context).pop(),
      onAdd: () {
        if (_timeController.text.isNotEmpty && _locationController.text.isNotEmpty) {
          final newAppointment = {
            'time': _timeController.text,
            'location': _locationController.text,
          };
          setState(() {
            final key = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
            _appointments[key] = [newAppointment];
            _selectedDay = selectedDay;
          });
          Navigator.of(context).pop();
        }
      },
      title: isEditing ? '약속 수정하기' : '새 약속 추가',
      isEditing: isEditing,
    );
  }

  Widget _buildDayCell(DateTime day, {required bool isSelected, required bool isToday, required bool isOutside}) {
    Color lineColor = isSelected ? const Color(0xFFD9C189) : isToday ? Colors.red : Colors.grey[300]!;
    Color textColor = (day.weekday == DateTime.sunday)
        ? (isOutside ? Colors.red[100]! : Colors.red)
        : (isOutside ? Colors.grey : Colors.black);

    BoxDecoration? decoration;
    if (isSelected || isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFD9C189) : Colors.red,
      );
    }

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
                style: TextStyle(color: isSelected || isToday ? Colors.white : textColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAppointments = _selectedDay != null
        ? _appointments[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const InfoAppBar(title: '약속 캘린더'),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_focusedDay.year}년 ${_focusedDay.month}월',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: Colors.grey[300]),
            TableCalendar(
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
              onDaySelected: (selectedDay, focusedDay) => setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              }),
              onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
              rowHeight: selectedAppointments.isNotEmpty ? 55 : 70,
              calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.zero,
                markersMaxCount: 1,
                markersAlignment: Alignment.bottomCenter,
              ),
              daysOfWeekHeight: 40,
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                  return Container(
                    height: 40,
                    color: const Color(0xFFD9C189),
                    alignment: Alignment.center,
                    child: Text(weekdays[day.weekday % 7], style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
                defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, isSelected: false, isToday: false, isOutside: false),
                todayBuilder: (context, day, focusedDay) => _buildDayCell(day, isSelected: false, isToday: true, isOutside: false),
                selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, isSelected: true, isToday: false, isOutside: false),
                outsideBuilder: (context, day, focusedDay) => _buildDayCell(day, isSelected: false, isToday: false, isOutside: true),
                markerBuilder: (context, date, events) {
                  final key = DateTime(date.year, date.month, date.day);
                  if (_appointments.containsKey(key) && _appointments[key]!.isNotEmpty) {
                    return Positioned(
                      bottom: 6,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD9C189),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const Divider(),
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
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
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD9C189)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20, color: Color(0xFFD9C189)),
                            const SizedBox(width: 8),
                            Text(selectedAppointments[0]['time']!, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD9C189)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place, size: 20, color: Color(0xFFD9C189)),
                            const SizedBox(width: 8),
                            Text(selectedAppointments[0]['location']!, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            child: const Text('수정', style: TextStyle(color: Color(0xFFD9C189))),
                            onPressed: () => _showAddOrEditSheet(_selectedDay!, existing: selectedAppointments[0]),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9C189),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              onPressed: () {},
                              child: const Text('공유', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                      : Center(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showAddOrEditSheet(_selectedDay!),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.access_time, size: 20, color: Color(0xFFD9C189)),
                          SizedBox(width: 8),
                          Text('약속 추가하기', style: TextStyle(color: Color(0xFFD9C189), fontSize: 20, fontWeight: FontWeight.w600)),
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
