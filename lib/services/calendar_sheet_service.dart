// 추후 코드 분기
/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/widgets/add_calendar_sheet.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';

class CalendarSheetService {
  /// 약속 추가/수정 바텀 시트를 표시합니다.
  static void showAddOrEditSheet(
      BuildContext context,
      DateTime selectedDay, {
        Map<String, dynamic>? existing,
        VoidCallback? onDelete,
        required Future<void> Function() onRefresh,
      }) {
    final isEditing = existing != null;
    final TextEditingController timeController =
    TextEditingController(text: existing?['time'] ?? '');
    final TextEditingController locationController =
    TextEditingController(text: existing?['location'] ?? '');

    showAddAppointmentSheet(
      context: context,
      timeController: timeController,
      locationController: locationController,
      title: isEditing ? '약속 수정하기' : '새 약속 추가',
      isEditing: isEditing,
      onCancel: () => Navigator.of(context).pop(),
      onAdd: () async {
        if (timeController.text.isEmpty || locationController.text.isEmpty) return;
        try {
          final kakaoId =
          Provider.of<UserController>(context, listen: false).userId!;
          final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
          final timeStr = timeController.text;
          final location = locationController.text;
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
          await onRefresh();
          Navigator.of(context).pop();
        } catch (e) {
          final msg = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
      onDelete: onDelete,
    );
  }
}

*/