import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fair_front/widgets/modify_button_row.dart';

// 약속 추가 & 수정 시트
class AddAppointmentSheet extends StatefulWidget {
  final TextEditingController timeController;
  final TextEditingController locationController;
  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;
  final String title;
  final bool isEditing;

  const AddAppointmentSheet({
    super.key,
    required this.timeController,
    required this.locationController,
    required this.onCancel,
    required this.onAdd,
    this.onDelete,
    required this.title,
    this.isEditing = false,
  });

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

// 시트 표시 함수
void showAddAppointmentSheet({
  required BuildContext context,
  required TextEditingController timeController,
  required TextEditingController locationController,
  required VoidCallback onCancel,
  required VoidCallback onAdd,
  required String title,
  bool isEditing = false,
  VoidCallback? onDelete,
}) {
  showCupertinoModalPopup(
    context: context,
    builder:
        (_) => AddAppointmentSheet(
          timeController: timeController,
          locationController: locationController,
          onCancel: onCancel,
          onAdd: onAdd,
          onDelete: onDelete,
          title: title,
          isEditing: isEditing,
        ),
  );
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  DateTime _selectedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.timeController.text.isNotEmpty) {
      try {
        _selectedTime = DateFormat('HH:mm').parse(widget.timeController.text);
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
        height: 400,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          children: [
            // 제목
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

            // 시간 선택
            CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(fontSize: 17),
                ),
              ),
              child: SizedBox(
                height: 85,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedTime,
                  use24hFormat: false,
                  onDateTimeChanged: (newTime) {
                    setState(() {
                      _selectedTime = newTime;
                      widget.timeController.text = DateFormat(
                        'HH:mm',
                      ).format(newTime);
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 장소 입력
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
              // 여러 줄 입력 가능
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 1,
            ),

            const Spacer(),

            // 버튼 Row
            ModifyButtonRow(
              isEditing: widget.isEditing,
              onAdd: widget.onAdd,
              onCancel: widget.onCancel,
              onDelete: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
