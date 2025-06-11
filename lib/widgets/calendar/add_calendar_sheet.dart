import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fair_front/widgets/calendar/modify_button_row.dart';

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
    // 키보드가 올라온 높이만큼 확보할 padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Container(
          // 화면 높이의 절반 + 키보드 높이 만큼 더 늘려줍니다.
          height: MediaQuery.of(context).size.height * 0.5 + bottomInset,
          color: Colors.white,
          // 키보드 높이만큼 하단 여백 추가
          padding: EdgeInsets.fromLTRB(16, 16, 16, 40 + bottomInset),
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
                // 시스템 다크모드와 무관하게 항상 밝은 테마로 고정
                data: CupertinoTheme.of(context).copyWith(
                  brightness: Brightness.light,
                  textTheme: const CupertinoTextThemeData(
                    // iOS-스타일 피커가 쓰는 두 스타일을 모두 지정
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                    pickerTextStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 150,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _selectedTime,
                    use24hFormat: false,
                    // 배경이 투명하면 글자가 사라져 보일 수 있으므로 흰색으로 고정
                    backgroundColor: Colors.white,
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
              // 이 TextField 아래로 키보드가 올라와도 가려지지 않도록
              CupertinoTextField(
                controller: widget.locationController,
                placeholder: '장소를 입력하세요',
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.place, size: 20, color: Color(0xFFD9C189)),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: Color(0xFFD9C189)),
                  borderRadius: BorderRadius.circular(8),
                ),
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
      ),
    );
  }
}
