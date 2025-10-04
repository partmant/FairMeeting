import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 캘린더 화면에서, 년월일 선택 다이얼
class MonthYearPickerSheet extends StatelessWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDatePicked;

  const MonthYearPickerSheet({
    super.key,
    required this.initialDate,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    DateTime tempPickedDate = initialDate;

    return Container(
      height: 350,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('취소', style: TextStyle(color: Colors.grey[900])),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('완료', style: TextStyle(color: Color(0xFFD9C189))),
                  onPressed: () {
                    onDatePicked(tempPickedDate);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDate,
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
  }
}

void showMonthYearPickerSheet({
  required BuildContext context,
  required DateTime initialDate,
  required ValueChanged<DateTime> onDatePicked,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (_) => MonthYearPickerSheet(
      initialDate: initialDate,
      onDatePicked: onDatePicked,
    ),
  );
}
