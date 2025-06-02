import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/appointment_service.dart';
import 'package:fair_front/widgets/calendar/add_calendar_sheet.dart';

// 외부에서 필요한 의존성을 모두 전달받는 형태로 작성
Future<void> showAddOrEditAppointmentDialog({
  required BuildContext context,
  required DateTime selectedDay,
  Map<String, dynamic>? existing,
  required TextEditingController timeController,
  required TextEditingController locationController,
  required Future<void> Function() reloadAppointments, // _loadAppointments와 같은 역할
}) async {
  // 기존 값이 있으면 컨트롤러에 미리 채워 넣기
  timeController.text = existing?['time'] ?? '';
  locationController.text = existing?['location'] ?? '';
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
        // 로그인 상태가 아니라면 토스트나 다이얼로그 띄우고 리턴
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 정보가 없습니다.'))
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

        // 약속 목록을 새로 불러와 화면 갱신
        await reloadAppointments();
        Navigator.of(context).pop();
      } catch (e) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg))
        );
      }
    },
    onDelete: () async {
      if (existing == null) return;
      final id = existing['id'] as int;
      final kakaoId = Provider.of<UserController>(context, listen: false).userId;
      if (kakaoId != null) {
        await AppointmentService.deleteAppointment(id: id, kakaoId: kakaoId);
        await reloadAppointments();
      }
    },
  );
}
