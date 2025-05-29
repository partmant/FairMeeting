import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAppointmentSheet extends StatefulWidget {
  final TextEditingController timeController;
  final TextEditingController locationController;
  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final String title;
  final bool isEditing;

  const AddAppointmentSheet({
    super.key,
    required this.timeController,
    required this.locationController,
    required this.onCancel,
    required this.onAdd,
    required this.title,
    this.isEditing = false,
  });

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  DateTime _selectedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.timeController.text.isNotEmpty) {
      try {
        _selectedTime = DateFormat('hh:mm a').parse(widget.timeController.text);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Container(
        height: 450,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD9C189),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 20),
            CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
              child: SizedBox(
                height: 85,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedTime,
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      _selectedTime = newTime;
                      widget.timeController.text =
                          DateFormat('hh:mm a').format(newTime);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: widget.locationController,
              placeholder: '장소를 입력하세요',
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.place, size: 20, color: Color(0xFFD9C189)),
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border.all(color: Color(0xFFD9C189)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('취소', style: TextStyle(color: Color(0xFFD9C189))),
                  onPressed: widget.onCancel,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9C189),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    // 버튼 텍스트를 isEditing 여부에 따라 동적으로 표시
                    child: Text(
                      widget.isEditing ? '수정' : '추가',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: widget.onAdd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showAddAppointmentSheet({
  required BuildContext context,
  required TextEditingController timeController,
  required TextEditingController locationController,
  required VoidCallback onCancel,
  required VoidCallback onAdd,
  required String title,
  bool isEditing = false,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (_) => AddAppointmentSheet(
      timeController: timeController,
      locationController: locationController,
      onCancel: onCancel,
      onAdd: onAdd,
      title: title,
      isEditing: isEditing,
    ),
  );
}
