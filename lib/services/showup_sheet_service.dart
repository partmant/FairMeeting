import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';
import 'package:fair_front/widgets/calendar/add_calendar_sheet.dart';

Future<void> showAddOrEditAppointmentDialog({
  required BuildContext context,
  required DateTime selectedDay,
  Map<String, dynamic>? existing,
  required TextEditingController timeController,
  required TextEditingController locationController,
  required Future<void> Function() reloadAppointments,
  String? initialLocationName,
}) async {

  // 1) 시간 컨트롤러 초기화 (기존 로직 그대로)
  timeController.text = existing?['time'] ?? '';

  // 2) 위치 컨트롤러 초기화
  if (existing != null) {
    // 수정 모드면 existing 데이터의 location 그대로 사용
    locationController.text = existing['location'] ?? '';
  } else {
    // 새 약속 추가 모드면, external(initialLocationName)이 있으면 그걸 사용하고 없으면 빈 문자열로
    if (initialLocationName != null && initialLocationName.isNotEmpty) {
      locationController.text = initialLocationName;
    } else {
      locationController.clear();
    }
  }

  final isEditing = existing != null;

  showAddAppointmentSheet(
    context: context,
    timeController: timeController,
    locationController: locationController,
    title: isEditing ? '약속 수정하기' : '새 약속 추가',
    isEditing: isEditing,
    onCancel: () {
      Navigator.of(context).pop();
    },
    onAdd: () async {
      // 입력값 검증
      if (timeController.text.isEmpty || locationController.text.isEmpty) return;

      final kakaoId = Provider.of<UserController>(context, listen: false).userId;
      if (kakaoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다.')),
        );
        return;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
      final timeStr = timeController.text;
      final location = locationController.text;

      try {
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

        // 약속 목록 다시 불러오기
        await reloadAppointments();
        Navigator.of(context).pop();
      } catch (e) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    },
    onDelete: () async {
      if (existing == null) return;
      final id = existing['id'] as int;
      final kakaoId =
          Provider.of<UserController>(context, listen: false).userId;
      if (kakaoId != null) {
        await AppointmentService.deleteAppointment(
          id: id,
          kakaoId: kakaoId,
        );
        await reloadAppointments();
      }
    },
  );
}
