package net.skhu.controller;

import java.util.Collections;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import net.skhu.dto.AppointmentCreateResponse;
import net.skhu.dto.AppointmentDto;
import net.skhu.dto.UserDto;
import net.skhu.mapper.AppointmentMapper;
import net.skhu.mapper.UserMapper;

@RestController
@RequestMapping("/api/appointments")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentMapper appointmentMapper;
    private final UserMapper userMapper;

    /** 약속 생성 (POST /api/appointments) */
    @PostMapping
    public ResponseEntity<?> createAppointment(@RequestBody AppointmentRequest req) {
        UserDto user = userMapper.findByKakaoId(req.getKakaoId());
        if (user == null) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body("회원만 약속을 저장할 수 있습니다.");
        }
        AppointmentDto exist = appointmentMapper.findByUserIdAndDate(user.getId(), req.getDate());
        if (exist != null) {
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body("이미 해당 날짜에 약속이 있습니다.");
        }
        AppointmentDto appt = new AppointmentDto();
        appt.setUserId(user.getId());
        appt.setDate(req.getDate());
        appt.setTime(req.getTime());
        appt.setLocation(req.getLocation());
        appointmentMapper.insert(appt);

        // 4) 메시지 + ID 함께 반환
        AppointmentCreateResponse resp =
            new AppointmentCreateResponse(appt.getId(), "약속이 저장되었습니다.");

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(resp);
    }

    /** 약속 목록 조회 (GET /api/appointments?kakaoId=…) */
    @GetMapping
    public ResponseEntity<List<AppointmentDto>> getAppointments(
            @RequestParam("kakaoId") String kakaoId) {

        UserDto user = userMapper.findByKakaoId(kakaoId);
        if (user == null) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.emptyList());
        }
        List<AppointmentDto> list = appointmentMapper.findByUserId(user.getId());
        return ResponseEntity.ok(list);
    }

    /** 수정 (PUT /api/appointments/{id}) */
    @PutMapping("/{id}")
    public ResponseEntity<String> updateAppointment(
            @PathVariable int id,
            @RequestBody AppointmentRequest req) {

        UserDto user = userMapper.findByKakaoId(req.getKakaoId());
        if (user == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("로그인 필요");
        }
        AppointmentDto exist = appointmentMapper.findById(id);
        if (exist == null || exist.getUserId() != user.getId()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("해당 약속이 없습니다.");
        }
        AppointmentDto dup = appointmentMapper.findByUserIdAndDate(user.getId(), req.getDate());
        if (dup != null && dup.getId() != id) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("이미 해당 날짜에 약속이 있습니다.");
        }
        AppointmentDto updated = new AppointmentDto();
        updated.setId(id);
        updated.setUserId(user.getId());
        updated.setDate(req.getDate());
        updated.setTime(req.getTime());
        updated.setLocation(req.getLocation());
        appointmentMapper.update(updated);
        return ResponseEntity.ok("약속이 수정되었습니다.");
    }

    /** 삭제 (DELETE /api/appointments/{id}?kakaoId=…) */
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteAppointment(
            @PathVariable int id,
            @RequestParam("kakaoId") String kakaoId) {

        UserDto user = userMapper.findByKakaoId(kakaoId);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("로그인 필요");
        }
        AppointmentDto exist = appointmentMapper.findById(id);
        if (exist == null || exist.getUserId() != user.getId()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("해당 약속이 없습니다.");
        }
        appointmentMapper.delete(id);
        return ResponseEntity.ok("약속이 삭제되었습니다.");
    }

    @Data
    static class AppointmentRequest {
        private String kakaoId;
        private String date;
        private String time;
        private String location;
    }

} // 여기서만 닫습니다
