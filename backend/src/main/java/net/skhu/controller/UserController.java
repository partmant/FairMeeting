package net.skhu.controller;

import net.skhu.dto.UserDto;
import net.skhu.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    UserMapper userMapper;

    @PostMapping
    public String registerOrUpdateUser(@RequestBody UserDto user) {
        log.info("사용자 로그인/등록 요청 수신: kakaoId={}, nickname={}", 
                 user.getKakaoId(), user.getNickname());

        // kakaoId로 기존 사용자 조회
        UserDto existing = userMapper.findByKakaoId(user.getKakaoId());

        if (existing == null) {
            // 존재하지 않으면 신규 INSERT
            int inserted = userMapper.insert(user);
            if (inserted > 0) {
                log.info("신규 회원 등록 완료: kakaoId={}", user.getKakaoId());
                return "회원 등록 완료";
            } else {
                log.error("회원 등록 실패: kakaoId={}", user.getKakaoId());
                return "회원 등록에 실패했습니다.";
            }
        } else {
            // 이미 존재하면 정보가 변경되었는지 체크 후 UPDATE
            boolean needUpdate = false;
            // nickname 또는 profileImageUrl 중 하나라도 다르면 업데이트
            if (!existing.getNickname().equals(user.getNickname())) {
                needUpdate = true;
            }
            if (user.getProfileImageUrl() != null 
                && !user.getProfileImageUrl().equals(existing.getProfileImageUrl())) {
                needUpdate = true;
            }

            if (needUpdate) {
                int updated = userMapper.update(user);
                if (updated > 0) {
                    log.info("기존 회원 정보 갱신 완료: kakaoId={}", user.getKakaoId());
                    return "회원 정보 업데이트 완료";
                } else {
                    log.error("회원 정보 업데이트 실패: kakaoId={}", user.getKakaoId());
                    return "회원 정보 업데이트에 실패했습니다.";
                }
            } else {
                log.info("기존 회원, 변경사항 없음: kakaoId={}", user.getKakaoId());
                return "이미 최신 상태인 회원입니다.";
            }
        }
    }
}
