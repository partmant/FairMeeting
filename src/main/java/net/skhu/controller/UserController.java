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
    public String registerUser(@RequestBody UserDto user) {
        log.info("💬 사용자 등록 요청 수신: {}", user.getNickname()); // 이 로그가 출력돼야 실제 요청이 온 것
        UserDto existing = userMapper.findByKakaoId(user.getKakaoId());
        if (existing == null) {
            userMapper.insert(user);
            return "회원 등록 완료";
        } else {
            return "이미 등록된 회원입니다.";
        }
    }
}
